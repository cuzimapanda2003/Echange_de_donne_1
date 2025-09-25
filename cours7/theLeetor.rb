#pour run le programme: ruby /home/etd/EchangeDeDonne/cours7/theLeetor.rb


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
   

post "/" do 
 name = request.body.read 



 # name = String(params["name"]) rescue nil  si on veut en query
  name.swapcase!

  transformation =  {
 "A" => "@",
 "E" => "3",
 "S" => "$",
 "T" => '+'
}

 transformation.each do |lettre, remplacement|
    name.gsub!(lettre, remplacement)
  end

  "#{name}"


end



        run! if app_file == $0
end
