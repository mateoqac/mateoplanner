require_relative "../../../../lib/mateoplanner/repositories/itinerary_repository"
require_relative "../../../../lib/mateoplanner/middleware/admin_auth"

module Mateoplanner
  module Actions
    module Admin
      module Itineraries
        class Index < Mateoplanner::Action
          def handle(request, response)
            unless Middleware::AdminAuth.authenticated?(request)
              response.redirect_to "/admin/login"
              return
            end

            repository = Repositories::ItineraryRepository.new
            itineraries = repository.all

            response.format = :html
            response.body = render_index(itineraries)
          end

          private

          def render_index(itineraries)
            <<~HTML
              <!DOCTYPE html>
              <html>
              <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Admin - Itinerary Queue</title>
                <link rel="stylesheet" href="/assets/styles.css">
                <style>
                  .admin-header {
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    padding: 20px 40px;
                    background: #f8f9fa;
                    border-bottom: 2px solid #dee2e6;
                  }
                  .itinerary-list {
                    padding: 40px;
                  }
                  .itinerary-item {
                    background: white;
                    border: 2px solid #dee2e6;
                    border-radius: 8px;
                    padding: 20px;
                    margin-bottom: 20px;
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                  }
                  .itinerary-info h3 {
                    margin-bottom: 10px;
                  }
                  .itinerary-meta {
                    font-size: 0.9rem;
                    color: #666;
                  }
                  .status-badge {
                    padding: 6px 12px;
                    border-radius: 4px;
                    font-size: 0.85rem;
                    font-weight: 600;
                    margin-right: 10px;
                  }
                  .status-badge.pending { background: #fff3cd; color: #856404; }
                  .status-badge.in_review { background: #d1ecf1; color: #0c5460; }
                  .status-badge.completed { background: #d4edda; color: #155724; }
                </style>
              </head>
              <body>
                <div class="container" style="max-width: 1400px;">
                  <div class="admin-header">
                    <h1>Itinerary Review Queue</h1>
                    <form action="/admin/logout" method="POST">
                      <input type="hidden" name="_method" value="DELETE">
                      <button type="submit" class="btn" style="background: #dc3545; color: white;">Logout</button>
                    </form>
                  </div>

                  <div class="itinerary-list">
                    <h2 style="margin-bottom: 20px;">All Itineraries (#{itineraries.length})</h2>
                    #{render_itineraries(itineraries)}
                  </div>
                </div>
              </body>
              </html>
            HTML
          end

          def render_itineraries(itineraries)
            if itineraries.empty?
              return "<p>No itineraries yet.</p>"
            end

            itineraries.map do |it|
              <<~HTML
                <div class="itinerary-item">
                  <div class="itinerary-info">
                    <h3>#{it[:destination]}</h3>
                    <div class="itinerary-meta">
                      <span class="status-badge #{it[:status]}">#{it[:status].upcase}</span>
                      <span>#{format_date(it[:start_date])} - #{format_date(it[:end_date])}</span> •
                      <span>#{it[:travel_companions]}</span> •
                      <span>Budget: #{it[:budget_range]}</span> •
                      <span>Submitted: #{format_datetime(it[:submitted_at])}</span>
                    </div>
                  </div>
                  <div class="itinerary-actions">
                    <a href="/admin/itineraries/#{it[:uuid]}" class="btn btn-primary">Review</a>
                  </div>
                </div>
              HTML
            end.join
          end

          def format_date(date)
            Date.parse(date.to_s).strftime("%b %d, %Y")
          end

          def format_datetime(datetime)
            return "N/A" unless datetime
            Time.parse(datetime.to_s).strftime("%b %d, %Y %H:%M")
          end
        end
      end
    end
  end
end
