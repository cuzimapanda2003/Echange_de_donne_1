#pour run le programme: ruby /home/etd/EchangeDeDonne/cours7/caractorgen.rb


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
require 'date'


class ServeurHttpServer < Sinatra::Base

    configure :development do
        register Sinatra::Reloader
    end

    set :bind, "0.0.0.0"
    set :port, "5678"



    def character(firstname, lastname, birthday) 
    date_of_birth = Date.strptime(birthday, "%Y-%m-%d")

    typeValue = firstname.count("aeiouy") + lastname.count("aeiouy");
    types = ["mage", "knight", "rogue", "barbarian", "monk", "druid", "ranger", "paladin"]
    type = types[typeValue % types.length]

    if typeValue.even?
        name = "#{lastname} #{firstname}".reverse
    else
        name = (firstname + lastname).chars.shuffle.join.insert(typeValue, " ")
    end

    raceValue = (firstname.length + lastname.length) * date_of_birth.year / (date_of_birth.day + date_of_birth.month)
    races = ["dwarf", "elf", "human", "orc", "fairy"]
    race = races[raceValue % races.length]

    {
        name: name,
        type: type,
        race: race
    }
    end
   

post "/" do 
  content_type :json

  firstname = params["firstname"]
  lastname = params["lastname"]
  date_of_birth = params["date_of_birth"]

  character = character(firstname, lastname, date_of_birth)
  character.to_json
end




        run! if app_file == $0
end
