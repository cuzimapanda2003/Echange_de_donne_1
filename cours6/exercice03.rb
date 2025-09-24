#pour run le programme: ruby /home/etd/EchangeDeDonne/cours6/exercice03.rb


require "bundler/inline"

gemfile do
    source "http://rubygems.org"
    gem "faraday"
end

require "faraday"

URL = "https://cegep.jhoffman.ca/ed-1/02_3-exercices/charactor/client_exercices_charactor.sinatra"


response = Faraday.post URL,{firstname:"Marc-Antoine", lastname: "Blais", date_of_birth: "2003-11-16"}
p response.body


