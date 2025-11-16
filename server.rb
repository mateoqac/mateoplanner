#!/usr/bin/env ruby

require_relative "config/boot"
require "puma"

class MateoplannerApp
  def call(env)
    request = Rack::Request.new(env)
    path = request.path
    method = request.request_method

    # Route matching
    action = route(path, method)

    if action
      response = Rack::Response.new
      action.call(request, response)
      response.finish
    else
      # Serve static files
      if path.start_with?("/assets/")
        static = Rack::Static.new(
          ->(_env) { [404, {}, ["Not Found"]] },
          urls: ["/assets"],
          root: "public"
        )
        return static.call(env)
      end

      [404, {"content-type" => "text/html"}, ["<h1>404 Not Found</h1>"]]
    end
  end

  private

  def route(path, method)
    case [method, path]
    when ["GET", "/"]
      Mateoplanner::Actions::Home::Index.new
    when ["GET", "/questionnaire"]
      Mateoplanner::Actions::Questionnaire::Show.new
    when ["POST", "/questionnaire"]
      Mateoplanner::Actions::Questionnaire::Create.new
    when ["GET", %r{^/itineraries/(.+)$}]
      Mateoplanner::Actions::Itineraries::Show.new
    when ["GET", "/admin/login"]
      Mateoplanner::Actions::Admin::Sessions::New.new
    when ["POST", "/admin/login"]
      Mateoplanner::Actions::Admin::Sessions::Create.new
    when ["POST", "/admin/logout"], ["DELETE", "/admin/logout"]
      Mateoplanner::Actions::Admin::Sessions::Destroy.new
    when ["GET", "/admin/itineraries"]
      Mateoplanner::Actions::Admin::Itineraries::Index.new
    when ["GET", %r{^/admin/itineraries/(.+)$}]
      Mateoplanner::Actions::Admin::Itineraries::Show.new
    when ["POST", %r{^/admin/itineraries/(.+)/enhance$}]
      Mateoplanner::Actions::Admin::Itineraries::Enhance.new
    when ["PATCH", %r{^/admin/itineraries/(.+)$}]
      Mateoplanner::Actions::Admin::Itineraries::Update.new
    else
      nil
    end
  end
end

puts "Starting MateoPlanner on http://localhost:2300"
Rack::Handler::Puma.run(MateoplannerApp.new, Port: 2300, Silent: false)
