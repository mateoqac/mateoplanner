module Mateoplanner
  module Middleware
    class AdminAuth
      def self.authenticated?(request)
        token = request.cookies["admin_session"]
        return false unless token

        $admin_sessions ||= {}
        $admin_sessions.key?(token)
      end

      def self.current_admin_id(request)
        token = request.cookies["admin_session"]
        return nil unless token

        $admin_sessions ||= {}
        $admin_sessions[token]
      end
    end
  end
end
