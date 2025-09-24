#pour run le programme: ruby /home/etd/EchangeDeDonne/cours7/route.rb

require "bundler/inline"

gemfile do
    source "http://rubygems.org"

    gem "sinatra-contrib"
    gem "puma"
    gem "rackup"
end

require 'sinatra/base'
require 'sinatra/reloader'

class ServeurHttpServer < Sinatra::Base

    configure :development do
        register Sinatra::Reloader
    end

    set :bind, "0.0.0.0"
    set :port, "5678"

    #
    # REQUETES
    #

    # Chaque URL accessible dans l'application est une ROUTE

    get "/" do 
     # value = [7, 8, 9, 10]
      # value.to_json

       params.to_json

      # request.env["rack.request.query_hash"].inspect
    end


    get "/" do
        "Hello from Sinatra!"
    end

    get "/about" do
        "This app doesn't do much..."
    end

    # On peut recevoir des parametres

    # Dans la QUERY STRING
    # GET ou POST /greetings-query?name=james
    get "/greetings-query" do
        # name = params["name"]
        name = request.env["rack.request.query_hash"]["name"]

        "Hello #{name} VS #{params[:name]}!"  
    end

    post "/greetings-query" do
        # name = params["name"]
        name = request.env["rack.request.query_hash"]["name"]

        "Hello #{name} VS #{params[:name]}!"  
    end

    # Dans le BODY form encoded
    # POST /greetings-body-form
    # Pourquoi pas un GET
    post "/greetings-body-form" do
        query_name = request.env["rack.request.query_hash"]["name"]
        form_name = request.env["rack.request.form_hash"]["name"]

        "Hello #{params[:name]} VS #{query_name} VS #{form_name}!"  
        # la variable params réuni les paramètres 
        # de query et du body form-encoded (et de route)
    end

    # Dans le BODY brut
    # POST /greetings-body
    post "/greetings-body" do
        name = request.body.read 
        name_again = request.body.read 

        request.body.rewind
        name_reset = request.body.read 

        "Hello #{name},\nagain, #{name_again},\nok now, #{name_reset}!" 
    end

    #
    #  REPONSES
    #  GET ou POST
    #

    # On doit retourner une String ou un item Enumerable
    # qui renvoie uniquement des string

    get "/response-text" do
        "Texte brut"
    end

    get "/response-array" do
        # ["1", "2", "3"]

        [1, 2, 3].map do |v|
            v.to_s
        end
    end

    # Le JSON est tres flexible
    # pour representer des données complexes
    # en format texte

    get "/response-array-json" do
        [1, 2, 3].to_json
    end

    get "/response-hash" do
        # Version longue
        # { 
        #   "firstname" => "James",
        #   "lastname" => "Hoffman"
        # }.to_json

        {
            firstname: "James",
            lastname: "Hoffman"
        }.to_json
    end

    get "/response-file" do
        send_file File.join(__dir__, "data.txt")
    end


    #DSL
    #Domain Specific Language

    run! if app_file == $0
end