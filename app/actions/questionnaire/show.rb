module Mateoplanner
  module Actions
    module Questionnaire
      class Show < Mateoplanner::Action
        def handle(request, response)
          response.format = :html
          template = File.read(File.join(__dir__, "../../templates/questionnaire/show.html.erb"))
          response.body = template
        end
      end
    end
  end
end
