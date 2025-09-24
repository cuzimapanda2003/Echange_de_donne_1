#pour run le programme: ruby /home/etd/EchangeDeDonne/cours6/exercice02.rb

require "bundler/inline"

gemfile do
    source "http://rubygems.org"
    gem "faraday"
end

require "faraday"

URL = "https://cegep.jhoffman.ca/ed-1/02_3-exercices/leet/client_exercices_leet.sinatra"


response = Faraday.post URL, "allo tout le monde", {"Content-type": "text/plain"}
p response.body




