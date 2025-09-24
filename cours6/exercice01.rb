
#pour run le programme: ruby /home/etd/EchangeDeDonne/cours6/exercice01.rb


require "bundler/inline"

gemfile do
    source "http://rubygems.org"
    gem "faraday"
end

require "faraday"

HOST = "https://cegep.jhoffman.ca"
BASE = "/ed-1/02_3-exercices/multiplicator/client_exercices_multiplicator.sinatra" 
URL = "https://cegep.jhoffman.ca/ed-1/02_3-exercices/multiplicator/client_exercices_multiplicator.sinatra"


response = Faraday.get URL, {number: 3}

body = response.body

table = JSON.parse body, synbolize_name: true rescue nil

if table
    puts JSON.pretty_generate(table)
 # table.each do |item|
   # puts item
 # end
else
    puts "erreurs"
end