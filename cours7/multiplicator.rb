#pour run le programme: ruby /home/etd/EchangeDeDonne/cours7/multiplicator.rb

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
require 'json'

class ServeurHttpServer < Sinatra::Base

    configure :development do
        register Sinatra::Reloader
    end

    set :bind, "0.0.0.0"
    set :port, "5678"
   

get "/" do 
  number = Integer(params["number"]) rescue nil

  if number
    content_type :json
    return number.times.map { |n|
      {
        "multiplicand": n,
        "multiplier": number,
        "product": n * number
      }
    }.to_json
  else
    "fournir un nombre"
  end
end



        run! if app_file == $0
end
