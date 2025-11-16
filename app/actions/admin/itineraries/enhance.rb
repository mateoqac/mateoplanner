require_relative "../../../../lib/mateoplanner/repositories/itinerary_repository"
require_relative "../../../../lib/mateoplanner/middleware/admin_auth"
require_relative "../../../../lib/mateoplanner/events/event_bus"
require_relative "../../../../lib/mateoplanner/events/itinerary_enhanced"
require_relative "../../../../lib/mateoplanner/events/review_started"
require "json"

module Mateoplanner
  module Actions
    module Admin
      module Itineraries
        class Enhance < Mateoplanner::Action
          def handle(request, response)
            unless Middleware::AdminAuth.authenticated?(request)
              response.redirect_to "/admin/login"
              return
            end

            uuid = request.params[:id]
            enhanced_content = request.params[:enhanced_content]
            action_type = request.params[:action]

            repository = Repositories::ItineraryRepository.new
            itinerary = repository.find_by_uuid(uuid)

            if itinerary.nil?
              response.status = 404
              response.headers['content-type'] = 'text/html'
              response.body = ["<h1>Itinerary not found</h1>"]
              return
            end

            # Validate JSON
            begin
              parsed_content = JSON.parse(enhanced_content)
            rescue JSON::ParserError => e
              response.status = 422
              response.headers['content-type'] = 'text/html'
              response.body = [render_error("Invalid JSON: #{e.message}")]
              return
            end

            admin_id = Middleware::AdminAuth.current_admin_id(request)
            event_bus = Events::EventBus.instance

            case action_type
            when "save_draft"
              # Just update the enhanced content
              repository.update(
                itinerary[:id],
                expert_enhanced_content: enhanced_content,
                status: "in_review"
              )

              # Publish ReviewStarted event if not already in review
              if itinerary[:status] == "pending"
                event_bus.publish(
                  Events::ReviewStarted.new(
                    itinerary_id: itinerary[:id],
                    admin_id: admin_id
                  )
                )
              end

              response.redirect_to "/admin/itineraries/#{uuid}"

            when "mark_complete"
              # Publish ItineraryEnhanced event (will update status to completed)
              event_bus.publish(
                Events::ItineraryEnhanced.new(
                  itinerary_id: itinerary[:id],
                  enhanced_content: parsed_content,
                  admin_id: admin_id
                )
              )

              response.redirect_to "/admin/itineraries"

            else
              response.status = 422
              response.headers['content-type'] = 'text/html'
              response.body = ["<h1>Invalid action</h1>"]
            end
          end

          private

          def render_error(message)
            <<~HTML
              <!DOCTYPE html>
              <html>
              <head>
                <meta charset="UTF-8">
                <title>Error</title>
                <link rel="stylesheet" href="/assets/styles.css">
              </head>
              <body>
                <div class="container" style="margin-top: 100px; max-width: 600px;">
                  <h1 style="color: #dc3545;">Error</h1>
                  <p>#{message}</p>
                  <a href="javascript:history.back()" class="btn btn-primary">Go Back</a>
                </div>
              </body>
              </html>
            HTML
          end
        end
      end
    end
  end
end
