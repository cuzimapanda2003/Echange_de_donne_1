require "bundler/inline"

gemfile do
    source "http://rubygems.org"

    gem "sinatra-contrib"

    gem "rackup"
    gem "puma"
end

require "sinatra/base"
require "sinatra/reloader"

class MySinatraApp < Sinatra::Base

    configure :development do
        register Sinatra::Reloader
    end

    #
    # VERBE
    #

    get "/" do
      return "Bonjour à tous!"
    end 

    # Une route est identifiee par le VERBE + CHEMIN
    # GET / est different de DELETE /
    delete "/" do
      return "Ceci est une action DELETE"
    end

    #
    # Parametre de chemin
    #
    get "/greetings/admin" do
      return "Bonjour cher admin!"
    end

    # ATTENTION, l'ordre de declaration des routes est important
    # /greetings/admin
    # /greetings/james
    get "/greetings/:name" do
      # On peut preciser un parametre dans le chemin

      return "Bonjour à #{params["name"]}!"
    end 

    #
    # Réponse: Status et Headers
    #

    # An Array with three elements: [status (Integer), headers (Hash), response body (responds to #each)]
    # An Array with two elements: [status (Integer), response body (responds to #each)]
    # An object that responds to #each and passes nothing but strings to the given block
    # A Integer representing the status code

    get "/status" do
      return 204
    end

    get "/status/body" do
      return [200, "Code 200, Tout est OK!"]
    end

    get "/status/body/headers" do
      data = { name: "James Hoffman", title: "Enseignant", age: 42 }
      headers = {
        "Content-Type"=> "application/json"
      } 

      return [
        200,
        headers,
        data.to_json
      ]
    end

    #
    # Requête: Headers
    #

    post "/headers" do
      # Les headers sont formatés selon les règles suivantes
      # - Nom en MAJUSCULE
      # - Les tirets - deviennent des barres de soulignement _
      # - Préfix HTTP_ 
      # Exemple: 
      #    Accept devient HTTP_ACCEPT
      #    User-Agent devient HTTP_USER_AGENT
      #
      # EXCEPTIONS
      #    CONTENT_LENGTH, CONTENT_TYPE

      # Les données complémentaires de la requête
      # sont disponible dans le Hash request.env
      # Plusieurs helpers simplifient l'accès
      # https://www.rubydoc.info/github/rack/rack/Rack/Request/Helpers
      return [
        request.content_type,

        request.user_agent,
        
        request.accept?("application/json").to_s,

        request.has_header?("CONTENT_TYPE").to_s,
        request.get_header("CONTENT_TYPE"),

        request.get_header("HTTP_MY_HEADER"),

        request.env.to_s,
        request.env["HTTP_MY_HEADER"],
      ].join("\n\n\n\n")
    end

    run! if app_file == $0
end