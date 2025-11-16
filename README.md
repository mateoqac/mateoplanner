# MateoPlanner - AI-Powered European Travel Itinerary Generator

An event-based travel planning application built with Hanami 2.3 that combines AI-generated itineraries with expert human enhancement.

## Features

- **User Questionnaire**: Collect travel preferences without requiring user accounts
- **AI Itinerary Generation**: OpenAI-powered personalized itineraries generated in under 60 seconds
- **Expert Enhancement**: Admin interface for travel experts to review and enhance AI itineraries
- **Weather Integration**: Real-time weather forecasts for travel destinations
- **Event-Driven Architecture**: Built using event sourcing patterns for scalability and maintainability

## Event-Based Architecture

The application uses an event-driven architecture with the following events:

- `ItineraryRequested`: Published when a user submits the questionnaire
- `ItineraryGenerated`: Published when AI completes itinerary generation
- `ReviewStarted`: Published when admin begins reviewing an itinerary
- `ItineraryEnhanced`: Published when admin completes enhancement

### Event Flow

```
User Submits Form
    → ItineraryRequested Event
        → GenerateItineraryHandler (calls OpenAI)
            → ItineraryGenerated Event
                → StoreItineraryHandler (saves to DB)

Admin Reviews
    → ReviewStarted Event
        → UpdateReviewStatusHandler (updates status)

Admin Completes Enhancement
    → ItineraryEnhanced Event
        → FinalizeEnhancementHandler (marks complete)
```

## Prerequisites

- Ruby 3.3.6
- SQLite3
- OpenAI API key (for AI itinerary generation)
- OpenWeatherMap API key (optional, uses mock data if not provided)

## Setup

1. **Install dependencies:**
   ```bash
   bundle install
   ```

2. **Configure environment variables:**
   ```bash
   cp .env.example .env
   ```

   Edit `.env` and add your API keys:
   ```
   OPENAI_API_KEY=your_openai_api_key_here
   WEATHER_API_KEY=your_weather_api_key_here
   ADMIN_EMAIL=admin@example.com
   ADMIN_PASSWORD=changeme
   ```

3. **Set up database:**
   ```bash
   bundle exec ruby db/setup.rb
   bundle exec ruby db/seed.rb
   ```

4. **Start the server:**
   ```bash
   bundle exec rackup -p 2300
   ```

5. **Visit the application:**
   - User interface: http://localhost:2300
   - Admin login: http://localhost:2300/admin/login
   - Default admin credentials: admin@example.com / changeme

## Project Structure

```
mateoplanner/
├── app/
│   ├── actions/          # Hanami actions (controllers)
│   ├── views/            # View objects
│   └── templates/        # HTML templates
├── lib/
│   └── mateoplanner/
│       ├── events/       # Event definitions
│       ├── handlers/     # Event handlers
│       ├── repositories/ # Data access layer
│       ├── services/     # Business logic services
│       └── middleware/   # Custom middleware
├── config/
│   ├── app.rb           # Application configuration
│   ├── routes.rb        # Route definitions
│   ├── events.rb        # Event system setup
│   └── boot.rb          # Application bootstrap
├── db/
│   ├── setup.rb         # Database schema
│   └── seed.rb          # Seed data
└── public/
    └── assets/          # CSS and static files
```

## Event System

Events are managed through a centralized `EventBus`:

```ruby
# Publishing an event
event_bus = Mateoplanner::Events::EventBus.instance
event_bus.publish(
  Mateoplanner::Events::ItineraryRequested.new(
    itinerary_id: 123,
    preferences: {...}
  )
)

# Event handlers are automatically called
# See config/events.rb for handler registration
```

## Usage

### User Flow

1. Visit the homepage and click "Start Planning Your Trip"
2. Fill out the questionnaire with travel preferences
3. Submit the form to trigger AI generation
4. View the generated itinerary at the unique URL
5. Wait for expert enhancement (status updates automatically)
6. Print or save the final itinerary

### Admin Flow

1. Login at /admin/login
2. View the review queue of all itineraries
3. Click "Review" on any itinerary
4. View user preferences and AI-generated content
5. Edit the JSON to add expert tips and enhancements
6. Save draft or mark as complete

## API Keys

### OpenAI API

Required for AI itinerary generation. Get your key from: https://platform.openai.com/api-keys

### OpenWeatherMap API

Optional for weather forecasts. Get your key from: https://openweathermap.org/api

If not provided, the application will use mock weather data.

## Development

### Running Tests

```bash
bundle exec rspec
```

### Database Reset

```bash
rm db/mateoplanner.db
bundle exec ruby db/setup.rb
bundle exec ruby db/seed.rb
```

## MVP Scope

This MVP includes:
- ✅ Single-page questionnaire form
- ✅ AI-powered itinerary generation (< 60 seconds)
- ✅ Day-by-day breakdown with activities and restaurants
- ✅ Weather forecasts for travel dates
- ✅ Admin authentication and review queue
- ✅ Expert enhancement interface
- ✅ Mobile-responsive design
- ✅ Print-friendly itinerary view
- ✅ Event-driven architecture

Out of scope for V1:
- Multi-step wizard
- User accounts
- Real-time booking integration
- Map visualization
- PDF downloads
- Multiple itinerary versions

## Technology Stack

- **Framework**: Hanami 2.3
- **Database**: SQLite3 with Sequel ORM
- **AI**: OpenAI GPT-4o-mini
- **Weather**: OpenWeatherMap API
- **Authentication**: Simple cookie-based sessions (admin only)
- **Server**: Puma
- **Architecture**: Event-driven with EventBus pattern

## License

MIT

## Contributing

This is an MVP project. For production use, consider:
- Adding proper session management (Redis/Memcached)
- Implementing background job processing (Sidekiq)
- Adding comprehensive test coverage
- Setting up proper logging and monitoring
- Implementing rate limiting
- Adding email notifications
- Using a production database (PostgreSQL)
