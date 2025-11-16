require_relative "base_event"

module Mateoplanner
  module Events
    class ItineraryEnhanced < BaseEvent
      def itinerary_id
        data[:itinerary_id]
      end

      def enhanced_content
        data[:enhanced_content]
      end

      def admin_id
        data[:admin_id]
      end
    end
  end
end
