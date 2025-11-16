require_relative "../../../../lib/mateoplanner/repositories/itinerary_repository"
require_relative "../../../../lib/mateoplanner/middleware/admin_auth"

module Mateoplanner
  module Actions
    module Admin
      module Itineraries
        class Show < Mateoplanner::Action
          def handle(request, response)
            unless Middleware::AdminAuth.authenticated?(request)
              response.redirect_to "/admin/login"
              return
            end

            uuid = request.params[:id]
            repository = Repositories::ItineraryRepository.new
            itinerary = repository.find_by_uuid(uuid)

            if itinerary.nil?
              response.status = 404
              response.body = "Itinerary not found"
              return
            end

            response.format = :html
            response.body = render_review(itinerary)
          end

          private

          def render_review(itinerary)
            content = itinerary[:ai_generated_content] || {}
            enhanced = itinerary[:expert_enhanced_content] || content

            <<~HTML
              <!DOCTYPE html>
              <html>
              <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Review: #{itinerary[:destination]} - Admin</title>
                <link rel="stylesheet" href="/assets/styles.css">
                <style>
                  .admin-review {
                    max-width: 1400px;
                  }
                  .review-layout {
                    display: grid;
                    grid-template-columns: 1fr 1fr;
                    gap: 30px;
                    padding: 40px;
                  }
                  .preferences-panel,
                  .itinerary-panel {
                    background: #f8f9fa;
                    padding: 20px;
                    border-radius: 8px;
                  }
                  .enhancement-form {
                    padding: 40px;
                    background: #fff;
                    border-top: 2px solid #dee2e6;
                  }
                  textarea.json-editor {
                    font-family: 'Courier New', monospace;
                    font-size: 0.9rem;
                    min-height: 400px;
                    width: 100%;
                    padding: 15px;
                    border: 2px solid #ddd;
                    border-radius: 6px;
                  }
                  .preference-item {
                    margin-bottom: 15px;
                    padding: 10px;
                    background: white;
                    border-radius: 4px;
                  }
                  .preference-item strong {
                    display: block;
                    color: #667eea;
                    margin-bottom: 5px;
                  }
                  .action-buttons {
                    display: flex;
                    gap: 15px;
                    margin-top: 20px;
                  }
                </style>
              </head>
              <body>
                <div class="container admin-review">
                  <header style="background: #343a40; color: white; padding: 20px 40px; display: flex; justify-content: space-between; align-items: center;">
                    <div>
                      <h1>Review Itinerary</h1>
                      <p>#{itinerary[:destination]} • #{format_date(itinerary[:start_date])} - #{format_date(itinerary[:end_date])}</p>
                    </div>
                    <a href="/admin/itineraries" class="btn" style="background: white; color: #343a40;">Back to Queue</a>
                  </header>

                  <div class="review-layout">
                    <div class="preferences-panel">
                      <h2 style="margin-bottom: 20px; color: #667eea;">User Preferences</h2>
                      #{render_preferences(itinerary)}
                    </div>

                    <div class="itinerary-panel">
                      <h2 style="margin-bottom: 20px; color: #667eea;">AI Generated Itinerary</h2>
                      <div style="background: white; padding: 15px; border-radius: 4px; max-height: 600px; overflow-y: auto;">
                        <pre style="white-space: pre-wrap; font-size: 0.85rem;">#{JSON.pretty_generate(content)}</pre>
                      </div>
                    </div>
                  </div>

                  <div class="enhancement-form">
                    <h2 style="margin-bottom: 20px; color: #667eea;">Enhance Itinerary</h2>
                    <p style="margin-bottom: 20px; color: #666;">
                      Edit the JSON below to add your expert enhancements, insider tips, and local recommendations.
                    </p>

                    <form action="/admin/itineraries/#{itinerary[:uuid]}/enhance" method="POST">
                      <div class="form-group">
                        <label for="enhanced_content">Enhanced Itinerary (JSON)</label>
                        <textarea id="enhanced_content" name="enhanced_content" class="json-editor" required>#{JSON.pretty_generate(enhanced)}</textarea>
                      </div>

                      <div class="action-buttons">
                        <button type="submit" name="action" value="save_draft" class="btn" style="background: #6c757d; color: white;">
                          Save Draft
                        </button>
                        <button type="submit" name="action" value="mark_complete" class="btn btn-primary">
                          Mark as Complete & Notify User
                        </button>
                      </div>
                    </form>

                    <div style="margin-top: 20px;">
                      <a href="/itineraries/#{itinerary[:uuid]}" target="_blank" class="btn" style="background: #17a2b8; color: white;">
                        Preview Itinerary
                      </a>
                    </div>
                  </div>
                </div>
              </body>
              </html>
            HTML
          end

          def render_preferences(itinerary)
            interests = itinerary[:interests].is_a?(Array) ? itinerary[:interests].join(", ") : itinerary[:interests]

            <<~HTML
              <div class="preference-item">
                <strong>Destination</strong>
                #{itinerary[:destination]}
              </div>
              <div class="preference-item">
                <strong>Dates</strong>
                #{format_date(itinerary[:start_date])} - #{format_date(itinerary[:end_date])}
              </div>
              <div class="preference-item">
                <strong>Budget</strong>
                #{itinerary[:budget_range]}
              </div>
              <div class="preference-item">
                <strong>Travel Pace</strong>
                #{itinerary[:travel_pace]}
              </div>
              <div class="preference-item">
                <strong>Interests</strong>
                #{interests}
              </div>
              <div class="preference-item">
                <strong>Accommodation</strong>
                #{itinerary[:accommodation_preference] || "No preference"}
              </div>
              <div class="preference-item">
                <strong>Travel Companions</strong>
                #{itinerary[:travel_companions]}
              </div>
              <div class="preference-item">
                <strong>Dietary Restrictions</strong>
                #{itinerary[:dietary_restrictions] || "None"}
              </div>
              <div class="preference-item">
                <strong>Special Requirements</strong>
                #{itinerary[:special_requirements] || "None"}
              </div>
              <div class="preference-item">
                <strong>Status</strong>
                <span class="status-badge #{itinerary[:status]}">#{itinerary[:status].upcase}</span>
              </div>
            HTML
          end

          def format_date(date)
            Date.parse(date.to_s).strftime("%B %d, %Y")
          end
        end
      end
    end
  end
end
