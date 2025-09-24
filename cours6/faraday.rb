#pour run le programme: ruby /home/etd/EchangeDeDonne/cours6/faraday.rb


require "bundler/inline"

gemfile do
    source "http://rubygems.org"
    gem "faraday"
end

require "faraday"

HOST = "https://cegep.jhoffman.ca"
BASE = "/ed-1/03_1-serveur-http/serveur_http_server.sinatra" 

# response = Faraday.get("https://cegep.jhoffman.ca/ed-1/03_1-serveur-http/serveur_http_server.sinatra/")
# Correspond a l'URL complete ci-dessus
response = Faraday.get (HOST + BASE + "/")

p response
p response.body


# Si on reutilise le meme service pour plusieurs requetes
# on peut preparer une connexion reutilisable

connection = Faraday.new (HOST + BASE)

# ATTENTION si l'URL de base de la connexion contient un PATH.
# les requetes subsequentes avec un PATH ABSOLU, /..., le remplaceront
# "https://cegep.jhoffman.ca/about", pas le bonne url du service
# response = connection.get("/about") 

# Il faut combiner le PATH de base manuellement a chaque fois
# "/ed-1/03_1-serveur-http/serveur_http_server.sinatra/about"
# response = connection.get(BASE + "/about")

# Sion, on peut utiliser une URL RELATIVE, qui ne commence PAS par /
# "https://cegep.jhoffman.ca/ed-1/03_1-serveur-http/serveur_http_server.sinatra/about"
response = connection.get "about"

p response.body


# Utilisons des url relative pour la suite

# Avec un parametre dans la QUERY STRING

# GET
response = connection.get "greetings-query", { name: "james" }

p response.body

# POST

# ATTENTION! Par default, form-urlencoded si post/put/patch
# https://lostisland.github.io/faraday/#/getting-started/quick-start?id=default-connection-default-adapter
#
# response = connection.post "greetings-query", { name: "james" }

response = connection.post "greetings-query" do |request|
  request.params["name"] = "james" # Query param explicite
end

p response.body


# Avec un parametre dans le BODY
# Attention, préciser qu'on veut le body en texte brute
response = connection.post "greetings-body", "james", { "Content-Type": "text/plain"}

p response.body


#
# Interpreter une reponse JSON
#


# Tableau JSON

response = connection.get "response-array-json"

p response.body

array = JSON.parse response.body
p array

array.each do |v|
  puts(v * 2)
end


# Objet JSON

response = connection.get "response-hash"
user = JSON.parse response.body

puts "Bonjour #{user["firstname"]} #{user["lastname"]}"

# Avec symboles
user = JSON.parse response.body, symbolize_names: true
puts "Bonjour #{user[:firstname]} #{user[:lastname]}"

#hash to json
h = {user: "marc", age: 21, height: 1.91}
p h.to_json
