#pour run le programme: ruby /home/etd/EchangeDeDonne/cours7/ServeurHttp.rb

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

class MySinatraApp < Sinatra::Base

    configure :development do
        register Sinatra::Reloader
    end

    set :bind, "0.0.0.0"
    set :port, "1234"

    # ...
    get "/" do
        "coucou"
    end

    run! if app_file == $0
end
