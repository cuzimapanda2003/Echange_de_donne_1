#pour run le programme: ruby /home/etd/EchangeDeDonne/cours7/exercices01.rb

require "bundler/inline"

gemfile do
    source "http://rubygems.org"

    gem "sinatra-contrib"
    gem "puma"
    gem "rackup"
    gem "faraday"
end

require 'sinatra/base'
require 'sinatra/reloader'
require "faraday"

URL = "http://localhost:5678/"

class ServeurHttpServer < Sinatra::Base

    configure :development do
        register Sinatra::Reloader
    end

    set :bind, "0.0.0.0"
    set :port, "5678"


    get "/" do 

    end








        run! if app_file == $0
end
