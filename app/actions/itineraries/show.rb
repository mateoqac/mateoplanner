require_relative '../../../lib/mateoplanner/repositories/itinerary_repository'
require_relative '../../../lib/mateoplanner/services/weather_service'

module Mateoplanner
  module Actions
    module Itineraries
      class Show < Mateoplanner::Action
        def handle(request, response)
          uuid = request.params[:id]

          repository = Repositories::ItineraryRepository.new
          itinerary = repository.find_by_uuid(uuid)

          if itinerary.nil?
            response.status = 404
            response.body = 'Itinerary not found'
            return
          end

          # Get weather forecast
          weather_service = Services::WeatherService.new
          city = extract_city(itinerary[:destination])
          days = (Date.parse(itinerary[:end_date].to_s) - Date.parse(itinerary[:start_date].to_s)).to_i + 1
          weather = weather_service.get_forecast(city, days)

          response.format = :html
          response.body = render_itinerary(itinerary, weather)
        end

        private

        def extract_city(destination)
          # Extract city name from "City, Country" format
          destination.split(',').first.strip
        end

        def render_itinerary(itinerary, weather)
          # Determine which content to display
          content = if itinerary[:expert_enhanced_content]
                      itinerary[:expert_enhanced_content]
                    elsif itinerary[:ai_generated_content]
                      itinerary[:ai_generated_content]
                    end

          status_message = case itinerary[:status]
                           when 'pending'
                             'Your itinerary is being generated... This usually takes less than 60 seconds. Please refresh the page.'
                           when 'in_review'
                             'Your itinerary has been generated and is being reviewed by our travel expert.'
                           when 'completed'
                             'Your expert-enhanced itinerary is ready!'
                           end

          # Render the template
          render_template(itinerary, content, weather, status_message)
        end

        def render_template(itinerary, content, weather, status_message)
          <<~HTML
            <!DOCTYPE html>
            <html>
            <head>
              <meta charset="UTF-8">
              <meta name="viewport" content="width=device-width, initial-scale=1.0">
              <title>Your Trip to #{itinerary[:destination]} - MateoPlanner</title>
              <link rel="stylesheet" href="/assets/styles.css">
              <link rel="stylesheet" href="/assets/print.css" media="print">
              #{auto_refresh_meta(itinerary[:status])}
            </head>
            <body>
              <div class="container itinerary-page">
                <header class="itinerary-header">
                  <h1>Your Trip to #{itinerary[:destination]}</h1>
                  <p class="trip-dates">#{format_date(itinerary[:start_date])} - #{format_date(itinerary[:end_date])}</p>
                  <p class="status-message #{itinerary[:status]}">#{status_message}</p>
                </header>

                #{render_weather_section(weather) if weather}

                <main class="itinerary-content">
                  #{render_content_section(content, itinerary)}
                </main>

                <footer>
                  <p>&copy; 2025 MateoPlanner | <a href="/">Create another itinerary</a></p>
                </footer>
              </div>
            </body>
            </html>
          HTML
        end

        def auto_refresh_meta(status)
          if status == 'pending'
            '<meta http-equiv="refresh" content="5">'
          else
            ''
          end
        end

        def format_date(date)
          Date.parse(date.to_s).strftime('%B %d, %Y')
        end

        def render_weather_section(weather)
          <<~HTML
            <section class="weather-section">
              <h2>Weather Forecast</h2>
              <div class="weather-grid">
                #{weather.map { |day| render_weather_day(day) }.join}
              </div>
            </section>
          HTML
        end

        def render_weather_day(day)
          <<~HTML
            <div class="weather-day">
              <div class="date">#{format_date(day[:date])}</div>
              <div class="condition">#{day[:condition]}</div>
              <div class="temp">#{day[:temp_min]}°C - #{day[:temp_max]}°C</div>
              <div class="description">#{day[:description]}</div>
            </div>
          HTML
        end

        def render_content_section(content, itinerary)
          return render_loading if content.nil?

          if content.is_a?(Hash) && content[:days]
            render_structured_itinerary(content, itinerary)
          else
            render_fallback_content(content)
          end
        end

        def render_loading
          <<~HTML
            <div class="loading">
              <p>Generating your personalized itinerary...</p>
              <p>This page will automatically refresh when ready.</p>
            </div>
          HTML
        end

        def render_structured_itinerary(content, itinerary)
          <<~HTML
            <section class="overview">
              <h2>Trip Overview</h2>
              <p>#{content[:overview] || content['overview']}</p>
              <p class="budget-estimate"><strong>Estimated Total Cost:</strong> #{content[:total_estimated_cost] || content['total_estimated_cost'] || 'TBD'}</p>
            </section>

            <section class="daily-itinerary">
              <h2>Daily Itinerary</h2>
              #{render_days(content[:days] || content['days'])}
            </section>

            #{render_expert_notes(itinerary) if itinerary[:status] == 'completed'}
          HTML
        end

        def render_days(days)
          return '' unless days

          days.map.with_index do |day, idx|
            <<~HTML
              <div class="day-card">
                <h3>Day #{day[:day] || day['day'] || idx + 1} - #{format_date(day[:date] || day['date'])}</h3>
                <div class="activities">
                  #{render_activities(day[:activities] || day['activities'])}
                </div>
              </div>
            HTML
          end.join
        end

        def render_activities(activities)
          return '' unless activities

          activities.map do |activity|
            type_class = activity[:type] || activity['type'] || 'activity'
            <<~HTML
              <div class="activity #{type_class}">
                <div class="activity-time">#{activity[:time] || activity['time']}</div>
                <div class="activity-details">
                  <h4>#{activity[:name] || activity['name']}</h4>
                  <p class="location">#{activity[:location] || activity['location']}</p>
                  <p class="description">#{activity[:description] || activity['description']}</p>
                  <div class="activity-meta">
                    <span class="duration">Duration: #{activity[:duration] || activity['duration']}</span>
                    <span class="cost">Cost: #{activity[:cost] || activity['cost']}</span>
                  </div>
                </div>
              </div>
            HTML
          end.join
        end

        def render_expert_notes(itinerary)
          <<~HTML
            <section class="expert-notes">
              <h2>Expert Enhancement</h2>
              <p class="enhanced-badge">This itinerary has been reviewed and enhanced by our travel expert!</p>
              <p class="completion-date">Completed on #{format_date(itinerary[:review_completed_at])}</p>
            </section>
          HTML
        end

        def render_fallback_content(content)
          <<~HTML
            <div class="raw-content">
              <pre>#{content.inspect}</pre>
            </div>
          HTML
        end
      end
    end
  end
end
