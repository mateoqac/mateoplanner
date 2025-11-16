require_relative "base_event"

module Mateoplanner
  module Events
    class ReviewStarted < BaseEvent
      def itinerary_id
        data[:itinerary_id]
      end

      def admin_id
        data[:admin_id]
      end
    end
  end
end
