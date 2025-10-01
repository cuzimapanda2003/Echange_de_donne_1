#pour run le programme: ruby /home/etd/EchangeDeDonne/cours7/livredorn.rb

require "bundler/inline"

gemfile do
    source "http://rubygems.org"

    gem "sinatra-contrib"
    # -contrib contient plusieurs extensions pratiques
    # https://sinatrarb.com/contrib/

    gem "rackup"
    gem "webrick"
end

require "sinatra/base"
require "sinatra/reloader"
require "date"

unless File.exists? "messages.json"
    messages_seed = [
            { name: "Marc", message: "Royal Recruit for the win", timestamp: DateTime.now.to_s },
            { name:"Médérick", message: "clash royal 2.6", timestamp: "2025-10-01T08:58:50-04:00"  },
            { name:"Émile", message: "log bait for the win", timestamp: "2025-10-01T08:58:23-04:00"  }
        
    ]

    File.write "messages.json", messages_seed.to_json
end

class MySinatraApp < Sinatra::Base

    configure :development do
        register Sinatra::Reloader
    end

    set :bind, "0.0.0.0"
    set :port, "1234"

    def get_mesages
JSON.parse File.read("messages.json"), symbolize_names: true rescue []
    end

    before{
        @messages = get_mesages
    }


    get "/" do 

    @messages.sort_by! do |m|
        m[:timestamp]
    end

    @messages.to_json


    end

    post "/" do 
       new_message = params
       new_message[:timestamp] = DateTime.now.to_s

        @messages << new_message

        File.write "messages.json", @messages.to_json

       ""
    end


    run! if app_file == $0
end