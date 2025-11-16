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
