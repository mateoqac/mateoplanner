require_relative "base_event"

module Mateoplanner
  module Events
    class ItineraryRequested < BaseEvent
      def itinerary_id
        data[:itinerary_id]
      end

      def preferences
        data[:preferences]
      end
    end
  end
end
