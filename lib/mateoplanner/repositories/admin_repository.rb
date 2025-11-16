require "sequel"
require "bcrypt"

module Mateoplanner
  module Repositories
    class AdminRepository
      def initialize(db = nil)
        @db = db || Sequel.connect("sqlite://db/mateoplanner.db")
      end

      def find_by_email(email)
        @db[:admins].where(email: email).first
      end

      def authenticate(email, password)
        admin = find_by_email(email)
        return nil unless admin

        password_matches = BCrypt::Password.new(admin[:password_digest]) == password
        password_matches ? admin : nil
      end
    end
  end
end
