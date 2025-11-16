module Mateoplanner
  module Middleware
    class AdminAuth
      def self.authenticated?(request)
        token = get_cookie(request, "admin_session")
        return false unless token

        $admin_sessions ||= {}
        $admin_sessions.key?(token)
      end

      def self.current_admin_id(request)
        token = get_cookie(request, "admin_session")
        return nil unless token

        $admin_sessions ||= {}
        $admin_sessions[token]
      end

      private

      def self.get_cookie(request, name)
        cookie_header = request.env["HTTP_COOKIE"]
        return nil unless cookie_header

        cookies = cookie_header.split(';').map(&:strip)
        cookie = cookies.find { |c| c.start_with?("#{name}=") }
        cookie ? cookie.split('=', 2)[1] : nil
      end
    end
  end
end
