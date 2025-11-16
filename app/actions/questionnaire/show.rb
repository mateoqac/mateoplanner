module Mateoplanner
  module Actions
    module Questionnaire
      class Show < Mateoplanner::Action
        def handle(_request, response)
          response.headers['content-type'] = 'text/html'
          template = File.read(File.join(__dir__, '../../templates/questionnaire/show.html.erb'))
          response.body = [template]
        end
      end
    end
  end
end
