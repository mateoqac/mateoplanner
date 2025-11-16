module Mateoplanner
  module Actions
    module Admin
      module Sessions
        class Destroy < Mateoplanner::Action
          def handle(request, response)
            # Get cookie from request
            cookie_header = request.env["HTTP_COOKIE"]
            if cookie_header
              cookies = cookie_header.split(';').map(&:strip)
              admin_cookie = cookies.find { |c| c.start_with?("admin_session=") }
              if admin_cookie
                token = admin_cookie.split('=', 2)[1]
                $admin_sessions ||= {}
                $admin_sessions.delete(token)
              end
            end

            # Clear the cookie
            response.headers["set-cookie"] = "admin_session=; Path=/; Max-Age=0"
            response.redirect_to "/"
          end
        end
      end
    end
  end
end
