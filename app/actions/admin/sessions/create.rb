require_relative "../../../lib/mateoplanner/repositories/admin_repository"
require "securerandom"

module Mateoplanner
  module Actions
    module Admin
      module Sessions
        class Create < Mateoplanner::Action
          def handle(request, response)
            email = request.params["email"]
            password = request.params["password"]

            repository = Repositories::AdminRepository.new
            admin = repository.authenticate(email, password)

            puts "  Authentication result: #{admin ? 'SUCCESS' : 'FAILED'}"

            if admin
              # Set session cookie (simple implementation for MVP)
              token = SecureRandom.hex(32)
              response.cookies["admin_session"] = {
                value: token,
                http_only: true,
                expires: Time.now + 86400 # 24 hours
              }

              # Store admin session (in production, use Redis or similar)
              $admin_sessions ||= {}
              $admin_sessions[token] = admin[:id]

              response.redirect_to "/admin/itineraries"
            else
              response.status = 401
              response.headers['content-type'] = 'text/html'
              response.body = [render_error]
            end
          end

          private

          def render_error
            <<~HTML
              <!DOCTYPE html>
              <html>
              <head>
                <meta charset="UTF-8">
                <title>Login Failed</title>
                <link rel="stylesheet" href="/assets/styles.css">
              </head>
              <body>
                <div class="container" style="margin-top: 100px; max-width: 600px;">
                  <h1 style="color: #dc3545;">Login Failed</h1>
                  <p>Invalid email or password.</p>
                  <a href="/admin/login" class="btn btn-primary">Try Again</a>
                </div>
              </body>
              </html>
            HTML
          end
        end
      end
    end
  end
end
