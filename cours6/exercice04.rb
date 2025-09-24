#pour run le programme: ruby /home/etd/EchangeDeDonne/cours6/exercice04.rb

require "bundler/inline"

gemfile do
  source "http://rubygems.org"
  gem "faraday"
end

require "faraday"

URL = "https://cegep.jhoffman.ca/ed-1/02_3-exercices/additionator/client_exercices_additionator.sinatra"

connection = Faraday.new URL

reponse = connection.get "query", { "inputs[]" => [2, 5, true, "allo"] }

puts reponse.body
