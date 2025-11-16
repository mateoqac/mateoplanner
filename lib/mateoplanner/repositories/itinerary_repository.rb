require "sequel"
require "securerandom"
require "json"

module Mateoplanner
  module Repositories
    class ItineraryRepository
      def initialize(db = nil)
        @db = db || Sequel.connect("sqlite://db/mateoplanner.db")
      end

      def create(attributes)
        attributes[:uuid] = SecureRandom.uuid
        attributes[:status] = "pending"
        attributes[:submitted_at] = Time.now
        attributes[:created_at] = Time.now
        attributes[:updated_at] = Time.now

        # Convert arrays to JSON strings
        attributes[:interests] = JSON.generate(attributes[:interests]) if attributes[:interests].is_a?(Array)

        id = @db[:itineraries].insert(attributes)
        find(id)
      end

      def find(id)
        @db[:itineraries].where(id: id).first
      end

      def find_by_uuid(uuid)
        record = @db[:itineraries].where(uuid: uuid).first
        parse_json_fields(record) if record
      end

      def update(id, attributes)
        attributes[:updated_at] = Time.now
        @db[:itineraries].where(id: id).update(attributes)
        find(id)
      end

      def all_pending
        @db[:itineraries]
          .where(status: "pending")
          .or(status: "in_review")
          .order(Sequel.desc(:created_at))
          .all
          .map { |r| parse_json_fields(r) }
      end

      def all
        @db[:itineraries]
          .order(Sequel.desc(:created_at))
          .all
          .map { |r| parse_json_fields(r) }
      end

      private

      def parse_json_fields(record)
        return nil unless record

        record[:interests] = JSON.parse(record[:interests]) if record[:interests].is_a?(String)
        record[:ai_generated_content] = JSON.parse(record[:ai_generated_content]) if record[:ai_generated_content].is_a?(String) && !record[:ai_generated_content].empty?
        record[:expert_enhanced_content] = JSON.parse(record[:expert_enhanced_content]) if record[:expert_enhanced_content].is_a?(String) && !record[:expert_enhanced_content].empty?
        record
      end
    end
  end
end
