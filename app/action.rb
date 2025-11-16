# Extend Rack::Response with redirect helper
module RackResponseExtensions
  def redirect_to(location, status = 302)
    self.status = status
    self.headers['location'] = location
    self.body = ["Redirecting to #{location}..."]
  end
end

Rack::Response.include(RackResponseExtensions)

module Mateoplanner
  class Action
    def call(request, response)
      handle(request, response)
    end

    def handle(request, response)
      raise NotImplementedError
    end
  end
end
