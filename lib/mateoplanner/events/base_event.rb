require "time"

module Mateoplanner
  module Events
    class BaseEvent
      attr_reader :occurred_at, :data

      def initialize(data = {})
        @data = data
        @occurred_at = Time.now
      end

      def event_type
        self.class.name.split("::").last
      end

      def to_h
        {
          event_type: event_type,
          occurred_at: occurred_at.iso8601,
          data: data
        }
      end
    end
  end
end
