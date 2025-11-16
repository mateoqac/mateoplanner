require "faraday"
require "json"

module Mateoplanner
  module Services
    class WeatherService
      API_URL = "https://api.openweathermap.org/data/2.5/forecast"

      def initialize(api_key = ENV["WEATHER_API_KEY"])
        @api_key = api_key
      end

      def get_forecast(city, days = 5)
        return mock_weather(city, days) if @api_key.nil? || @api_key == "your_weather_api_key_here"

        response = Faraday.get(API_URL, {
          q: city,
          appid: @api_key,
          units: "metric",
          cnt: days * 8 # 8 forecasts per day (every 3 hours)
        })

        if response.status == 200
          parse_weather(JSON.parse(response.body))
        else
          mock_weather(city, days)
        end
      rescue => e
        mock_weather(city, days)
      end

      private

      def parse_weather(data)
        forecasts = data["list"].group_by { |f| Time.at(f["dt"]).to_date }

        forecasts.map do |date, items|
          temps = items.map { |i| i["main"]["temp"] }
          conditions = items.map { |i| i["weather"].first["main"] }.uniq

          {
            date: date.to_s,
            temp_min: temps.min.round,
            temp_max: temps.max.round,
            condition: conditions.first,
            description: items.first["weather"].first["description"]
          }
        end
      end

      def mock_weather(city, days)
        (0...days).map do |i|
          date = Date.today + i
          {
            date: date.to_s,
            temp_min: 15 + rand(5),
            temp_max: 22 + rand(8),
            condition: ["Clear", "Clouds", "Rain"].sample,
            description: "partly cloudy"
          }
        end
      end
    end
  end
end
