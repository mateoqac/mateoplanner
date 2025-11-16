require_relative "../repositories/itinerary_repository"

module Mateoplanner
  module Handlers
    class UpdateReviewStatusHandler
      def initialize(event_bus)
        @event_bus = event_bus
        @repository = Repositories::ItineraryRepository.new
      end

      def call(event)
        puts "[UpdateReviewStatusHandler] Updating review status for #{event.itinerary_id}"

        @repository.update(
          event.itinerary_id,
          status: "in_review",
          review_started_at: Time.now
        )

        puts "[UpdateReviewStatusHandler] Review started for #{event.itinerary_id}"
      rescue => e
        puts "[UpdateReviewStatusHandler] Error: #{e.message}"
      end
    end
  end
end
