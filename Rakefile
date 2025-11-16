require "rom/sql"
require "rom/sql/rake_task"

namespace :db do
  task :setup do
    require_relative "config/app"
  end

  desc "Run migrations"
  task migrate: :setup do
    require "rom-sql"
    require "logger"

    config = ROM::Configuration.new(:sql, "sqlite://db/mateoplanner.db")
    config.gateways[:default].use_logger(Logger.new($stdout))

    ROM::SQL::RakeSupport.env = config

    ROM::SQL.migration do
      ROM::SQL::Migration::Migrator.run(config.gateways[:default], target: :up)
    end

    puts "Migrations completed!"
  end

  desc "Create database"
  task :create do
    require "fileutils"
    FileUtils.mkdir_p("db")
    FileUtils.touch("db/mateoplanner.db")
    puts "Database created at db/mateoplanner.db"
  end

  desc "Drop database"
  task :drop do
    require "fileutils"
    FileUtils.rm_f("db/mateoplanner.db")
    puts "Database dropped"
  end

  desc "Reset database"
  task reset: [:drop, :create, :migrate]

  desc "Create admin user"
  task :seed_admin => :setup do
    require "bcrypt"
    require "rom"
    require "rom-sql"

    rom = ROM.container(:sql, "sqlite://db/mateoplanner.db") do |config|
      config.relation(:admins) do
        schema(infer: true)
        auto_struct true
      end
    end

    email = ENV.fetch("ADMIN_EMAIL", "admin@example.com")
    password = ENV.fetch("ADMIN_PASSWORD", "changeme")
    password_digest = BCrypt::Password.create(password)

    # Check if admin already exists
    existing = rom.relations[:admins].where(email: email).one

    if existing
      puts "Admin user already exists: #{email}"
    else
      rom.relations[:admins].insert(
        email: email,
        password_digest: password_digest,
        created_at: Time.now,
        updated_at: Time.now
      )
      puts "Admin user created: #{email}"
      puts "Password: #{password}"
    end
  end
end
