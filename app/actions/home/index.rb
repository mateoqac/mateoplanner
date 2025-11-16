module Mateoplanner
  module Actions
    module Home
      class Index < Mateoplanner::Action
        def handle(request, response)
          response.headers["content-type"] = "text/html"
          template = File.read(File.join(__dir__, "../../templates/home/index.html.erb"))
          response.body = [template]
        end
      end
    end
  end
end
