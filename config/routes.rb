module Mateoplanner
  class Routes < Hanami::Routes
    root to: "home.index"

    # Questionnaire
    get "/questionnaire", to: "questionnaire.show"
    post "/questionnaire", to: "questionnaire.create"

    # Itineraries
    get "/itineraries/:id", to: "itineraries.show"

    # Admin
    get "/admin/login", to: "admin/sessions.new"
    post "/admin/login", to: "admin/sessions.create"
    delete "/admin/logout", to: "admin/sessions.destroy"

    get "/admin/itineraries", to: "admin/itineraries.index"
    get "/admin/itineraries/:id", to: "admin/itineraries.show"
    post "/admin/itineraries/:id/enhance", to: "admin/itineraries.enhance"
    patch "/admin/itineraries/:id", to: "admin/itineraries.update"
  end
end
