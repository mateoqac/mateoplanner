module Mateoplanner
  module Events
    class EventBus
      def initialize
        @subscribers = Hash.new { |h, k| h[k] = [] }
      end

      def subscribe(event_type, &handler)
        @subscribers[event_type] << handler
      end

      def publish(event)
        event_type = event.class.name.split("::").last
        @subscribers[event_type].each do |handler|
          handler.call(event)
        end
      end

      def self.instance
        @instance ||= new
      end
    end
  end
end
