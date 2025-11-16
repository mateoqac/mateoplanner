require "openai"
require "json"

module Mateoplanner
  module Services
    class AiItineraryGenerator
      def initialize(api_key = ENV["OPENAI_API_KEY"])
        @client = OpenAI::Client.new(access_token: api_key)
      end

      def generate(preferences)
        prompt = build_prompt(preferences)

        response = @client.chat(
          parameters: {
            model: "gpt-4o-mini",
            messages: [
              {
                role: "system",
                content: "You are an expert travel planner specializing in European destinations. You create detailed, personalized itineraries based on traveler preferences. Return your response as a valid JSON object."
              },
              {
                role: "user",
                content: prompt
              }
            ],
            temperature: 0.7,
            max_tokens: 3000
          }
        )

        content = response.dig("choices", 0, "message", "content")
        parse_itinerary(content)
      rescue => e
        {
          error: "Failed to generate itinerary: #{e.message}",
          days: []
        }
      end

      private

      def build_prompt(prefs)
        interests_list = prefs[:interests].is_a?(Array) ? prefs[:interests].join(", ") : prefs[:interests]

        <<~PROMPT
          Create a detailed travel itinerary with the following preferences:

          Destination: #{prefs[:destination]}
          Dates: #{prefs[:start_date]} to #{prefs[:end_date]}
          Budget: #{prefs[:budget_range]}
          Travel Pace: #{prefs[:travel_pace]}
          Interests: #{interests_list}
          Accommodation: #{prefs[:accommodation_preference]}
          Dietary Restrictions: #{prefs[:dietary_restrictions]}
          Travel Companions: #{prefs[:travel_companions]}
          Special Requirements: #{prefs[:special_requirements]}

          Please create a day-by-day itinerary that includes:
          - 2-4 activities per day based on the #{prefs[:travel_pace]} pace
          - Restaurant recommendations for breakfast, lunch, and dinner
          - Timing for each activity
          - Brief descriptions explaining why each recommendation fits their preferences
          - Estimated costs for each activity and meal
          - Only suggest real, currently operational places

          Return the response as a JSON object with this structure:
          {
            "overview": "Brief trip summary",
            "total_estimated_cost": "€X - €Y",
            "days": [
              {
                "day": 1,
                "date": "YYYY-MM-DD",
                "activities": [
                  {
                    "time": "9:00 AM",
                    "name": "Activity name",
                    "type": "activity|breakfast|lunch|dinner",
                    "location": "Address",
                    "description": "Why this fits their preferences",
                    "cost": "€X",
                    "duration": "2 hours"
                  }
                ]
              }
            ]
          }
        PROMPT
      end

      def parse_itinerary(content)
        # Try to extract JSON from markdown code blocks
        json_match = content.match(/```json\n(.*?)\n```/m) || content.match(/```\n(.*?)\n```/m)
        json_str = json_match ? json_match[1] : content

        JSON.parse(json_str)
      rescue JSON::ParserError => e
        # Fallback: return raw content if JSON parsing fails
        {
          overview: "Itinerary generated successfully",
          raw_content: content,
          days: []
        }
      end
    end
  end
end
