require "sequel"

DB = Sequel.connect("sqlite://db/mateoplanner.db")

# Create itineraries table
DB.create_table? :itineraries do
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

  index :uuid, unique: true
  index :status
end

# Create admins table
DB.create_table? :admins do
  primary_key :id
  String :email, null: false, unique: true
  String :password_digest, null: false

  DateTime :created_at
  DateTime :updated_at

  index :email, unique: true
end

puts "Database tables created successfully!"
