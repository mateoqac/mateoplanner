require_relative '../../../lib/mateoplanner/repositories/itinerary_repository'
require_relative '../../../lib/mateoplanner/events/event_bus'
require_relative '../../../lib/mateoplanner/events/itinerary_requested'

module Mateoplanner
  module Actions
    module Questionnaire
      class Create < Mateoplanner::Action
        def handle(request, response)
          params = request.params

          # Validate required fields
          errors = validate_params(params)

          if errors.any?
            response.status = 422
            response.headers['content-type'] = 'text/html'
            response.body = [render_errors(errors)]
            return
          end

          # Create itinerary record
          repository = Repositories::ItineraryRepository.new
          itinerary = repository.create(
            destination: params[:destination],
            start_date: Date.parse(params[:start_date]),
            end_date: Date.parse(params[:end_date]),
            budget_range: params[:budget_range],
            travel_pace: params[:travel_pace],
            interests: params[:interests] || [],
            accommodation_preference: params[:accommodation_preference],
            dietary_restrictions: params[:dietary_restrictions],
            travel_companions: params[:travel_companions],
            special_requirements: params[:special_requirements]
          )

          # Publish ItineraryRequested event
          event_bus = Events::EventBus.instance
          event_bus.publish(
            Events::ItineraryRequested.new(
              itinerary_id: itinerary[:id],
              preferences: itinerary
            )
          )

          # Redirect to processing page with UUID
          response.redirect_to "/itineraries/#{itinerary[:uuid]}"
        end

        private

        def validate_params(params)
          errors = []
          errors << 'Destination is required' if params[:destination].to_s.empty?
          errors << 'Start date is required' if params[:start_date].to_s.empty?
          errors << 'End date is required' if params[:end_date].to_s.empty?
          errors << 'Budget range is required' if params[:budget_range].to_s.empty?
          errors << 'Travel pace is required' if params[:travel_pace].to_s.empty?
          errors << 'Travel companions is required' if params[:travel_companions].to_s.empty?
          errors
        end

        def render_errors(errors)
          <<~HTML
            <!DOCTYPE html>
            <html>
            <head>
              <title>Error</title>
              <link rel="stylesheet" href="/assets/styles.css">
            </head>
            <body>
              <div class="container">
                <h1>Validation Errors</h1>
                <ul>
                  #{errors.map { |e| "<li>#{e}</li>" }.join}
                </ul>
                <a href="/questionnaire">Go Back</a>
              </div>
            </body>
            </html>
          HTML
        end
      end
    end
  end
end
