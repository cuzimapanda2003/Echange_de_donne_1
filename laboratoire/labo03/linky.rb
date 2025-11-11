# Marc-Antoie Blais 
require "bundler/inline"
require_relative 'auth'
require 'uri'
require 'net/http'


gemfile do
    source "http://rubygems.org"

    gem "sinatra-contrib"
    gem "rackup"
    gem "puma"
end

require "sinatra/base"
require "sinatra/reloader"
require "openssl"


LINKS_FILE = File.join __dir__, "links.json"

unless File.exists? LINKS_FILE
File.write LINKS_FILE, "[]"
end

def save_link
  File.write(LINKS_FILE, @links.to_json)
end


def url_valide?(url)
  uri = URI.parse(url)
  uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
rescue URI::InvalidURIError
  false
end

def url_accessible?(url)
  uri = URI.parse(url)

  Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 3, read_timeout: 3) do |http|
    response = http.head(uri.request_uri)
    unless response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPRedirection)
      request = Net::HTTP::Get.new(uri)
      response = http.request(request)
    end
    return response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPRedirection)
  end
rescue => e
  puts "Erreur lors de l'accès à #{url}: #{e.message}"
  false
end


def generate_hash
  SecureRandom.alphanumeric(6)
end

class CustomAuth < Sinatra::Base


    set :bind, "0.0.0.0"
    set :port, "1234"

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

            @user = authenticate(username, password)
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


     def get_links 
        return JSON.parse File.read(LINKS_FILE), symbolize_names: true rescue []
    end

    before {
        @links = get_links
    }


        get "/links" do 
            guard! # Oblige l'authentification pour cette route
             user_links = @links.select { |link| link[:name] == @user[:username] }.map { |link| link.slice(:link, :hash) }
             content_type :json
             user_links.to_json
        end


        post "/links" do
            guard! # Oblige l'authentification pour cette route
            links_params = JSON.parse request.body.read, symbolize_names: true rescue {}
            link = links_params[:link]

            if link.nil? || link.strip.empty?
            status 400
            headers({"Content-Type"=>"Text/plain"})
            return "lien requis..."
            end

            unless url_valide?(link)
            status 400
            return "URL invalide"
            end

            unless url_accessible?(link)
            status 400
            return "URL inaccessible"
            end

            hash = generate_hash

            new_link = {
                name: @user[:username],
                link: link,
                hash: hash
            }

            @links << new_link
            save_link
        
            status 201
            content_type :json
            new_link.to_json
    
         end


        delete "/links/:hash" do 
         guard!

          delete_index = @links.find_index { |link| link[:hash] == params[:hash] }

          if delete_index.nil?
          status 404
          return "Lien introuvable"
          end

          @links.delete_at(delete_index)
          save_link

         status 204
        end


     patch "/links/:hash" do 
       guard!

        patch_index = @links.find_index { |link| link[:hash] == params[:hash] }
         if patch_index.nil?
         status 404
        return "Lien introuvable"
       end

       links_params = JSON.parse(request.body.read, symbolize_names: true) rescue {}
       new_link = links_params[:link]

        if new_link.nil? || new_link.strip.empty?
        status 400
        return "Nouveau lien requis"
        end

        unless url_valide?(new_link)
        status 400
        return "URL invalide"
        end

       unless url_accessible?(new_link)
       status 400
       return "URL inaccessible"
       end

        @links[patch_index][:link] = new_link
        save_link

        status 200
        content_type :json
        @links[patch_index].to_json
      end


        get "/l/:hash" do 
          link_entry = @links.find{ |link| link[:hash] == params[:hash]}
          if link_entry.nil?
            status 404
            return "lien introuvable"
          end
         
          redirect link_entry[:link], 302
        end

        







    run! if app_file == $0
end



