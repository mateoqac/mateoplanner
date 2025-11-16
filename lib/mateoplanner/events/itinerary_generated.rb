require_relative "base_event"

module Mateoplanner
  module Events
    class ItineraryGenerated < BaseEvent
      def itinerary_id
        data[:itinerary_id]
      end

      def content
        data[:content]
      end
    end
  end
end
