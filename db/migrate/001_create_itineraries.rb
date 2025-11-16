ROM::SQL.migration do
  change do
    create_table :itineraries do
      primary_key :id
      String :uuid, null: false, unique: true

      # User preferences
      String :destination, null: false
      Date :start_date, null: false
      Date :end_date, null: false
      String :budget_range, null: false
      String :travel_pace, null: false
      String :interests, text: true # JSON array
      String :accommodation_preference
      String :dietary_restrictions, text: true
      String :travel_companions
      String :special_requirements, text: true

      # Generated itinerary (JSON)
      String :ai_generated_content, text: true
      String :expert_enhanced_content, text: true

      # Status tracking
      String :status, default: "pending" # pending, in_review, completed
      DateTime :submitted_at
      DateTime :review_started_at
      DateTime :review_completed_at

      DateTime :created_at
      DateTime :updated_at
    end

    add_index :itineraries, :uuid, unique: true
    add_index :itineraries, :status
  end
end
