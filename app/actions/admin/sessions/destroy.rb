module Mateoplanner
  module Actions
    module Admin
      module Sessions
        class Destroy < Mateoplanner::Action
          def handle(request, response)
            token = request.cookies["admin_session"]

            if token
              $admin_sessions ||= {}
              $admin_sessions.delete(token)
            end

            response.cookies["admin_session"] = {
              value: "",
              expires: Time.now - 86400
            }

            response.redirect_to "/"
          end
        end
      end
    end
  end
end
