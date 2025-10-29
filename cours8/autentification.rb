require "bundler/inline"

gemfile do
    source "http://rubygems.org"

    gem "sinatra-contrib"
    gem "rackup"
    gem "puma"
end

require "sinatra/base"
require "sinatra/reloader"
require "openssl"

SHA_KEY = "th3Superkey!" # Salt de hachage

class CustomAuth < Sinatra::Base

    configure :development do
        register Sinatra::Reloader
    end

    # On ne veut pas enregistrer de mot de passe en clair
    # le hachage sha256 permet d'empecher une fuite
    # des mots de passe pouvant amener a une attaque subsequente si réutilisé
    # https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html#background
    def sha256(value)
        nil if value.nil? || value.empty?

        OpenSSL::HMAC.hexdigest("sha256", SHA_KEY, value)
    end

    def authorize
        auth =  Rack::Auth::Basic::Request.new(request.env) 

        return unless auth.provided? && auth.basic? && auth.credentials

        username, password = auth.credentials 
        # auth.credentials est ["username", "password"]
        # https://docs.ruby-lang.org/en/3.1/syntax/assignment_rdoc.html#label-Array+Decomposition

        if username == "admin" && sha256(password) == "71b0e3e2c9d25193a93bf31beaed7c3cf08d2d39a37e52f79366af1b7f6bf9d6" # sha256("pwda")
            @user = username
        end
    end

    # Avant chaque route
    before do
        authorize
        # trouver l'utilisateur authentifié, s'il existe
    end

    def guard!
        auth_required = [
            401,
            { "WWW-Authenticate" => "Basic" },
            "Provide a username and password through Basic HTTP authentication"
        ]

        # HALT interrompt IMMEDIATEMENT la requête et retourne le resultat
        halt auth_required unless @user
    end

    get "/" do
        "Welcome!"
    end

    get "/hey" do
        message = @user || "[anonymous]"

        "Hey #{message} :)"
    end

    get "/private" do
        guard! # Oblige l'authentification pour cette route

        "Ahoy #{@user}"
    end

    run! if app_file == $0
end