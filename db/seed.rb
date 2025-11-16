require "sequel"
require "bcrypt"
require "dotenv/load"

DB = Sequel.connect("sqlite://db/mateoplanner.db")

email = ENV.fetch("ADMIN_EMAIL", "admin@example.com")
password = ENV.fetch("ADMIN_PASSWORD", "changeme")
password_digest = BCrypt::Password.create(password)

# Check if admin already exists
existing = DB[:admins].where(email: email).first

if existing
  puts "Admin user already exists: #{email}"
else
  DB[:admins].insert(
    email: email,
    password_digest: password_digest,
    created_at: Time.now,
    updated_at: Time.now
  )
  puts "Admin user created!"
  puts "Email: #{email}"
  puts "Password: #{password}"
end
