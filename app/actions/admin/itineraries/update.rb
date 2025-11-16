require_relative "../../../../lib/mateoplanner/repositories/itinerary_repository"
require_relative "../../../../lib/mateoplanner/middleware/admin_auth"

module Mateoplanner
  module Actions
    module Admin
      module Itineraries
        class Update < Mateoplanner::Action
          def handle(request, response)
            unless Middleware::AdminAuth.authenticated?(request)
              response.redirect_to "/admin/login"
              return
            end

            # Placeholder for future PATCH endpoint
            response.status = 501
            response.body = "Not implemented"
          end
        end
      end
    end
  end
end
