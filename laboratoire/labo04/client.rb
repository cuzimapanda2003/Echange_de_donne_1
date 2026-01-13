require "bundler/inline"
require "json"
require "faraday"
require "faraday/multipart"

gemfile do
  source "http://rubygems.org"
  gem "faraday"
  gem "faraday-multipart"
end

server = Faraday.new("http://localhost:1234") do |f|
  f.request :authorization, :basic, "bob", "pwdb"
  f.request :multipart
end

loop do
  puts "\nOptions:"
  puts "1: Liste des fichiers"
  puts "2: Voir un fichier"
  puts "3: Envoyer un fichier"
  puts "4: Modifier mot de passe"
  puts "5: Supprimer un fichier"
  puts "6: Blazediff"

  choix = gets.chomp

  case choix
  when "1"
    resp = server.get("/files")
    puts JSON.pretty_generate(JSON.parse(resp.body))

  when "2"
    print "UUID : "
    uuid = gets.chomp
    resp = server.get("/files/#{uuid}")
    if resp.status == 404
      puts "Fichier introuvable"
    elsif resp.status == 403
      puts "Accès refusé"
    else
      puts JSON.pretty_generate(JSON.parse(resp.body))
    end

  when "3"
    print "Nom du fichier (avec extension) : "
    fname = gets.chomp
    file_path = "images/#{fname}"
    unless File.exist?(file_path)
      puts "Fichier non trouvé"
      next
    end
    print "Mot de passe (vide si aucun) : "
    pass = gets.chomp
    data = { demo_file: Faraday::Multipart::FilePart.new(file_path, "text/plain"), password: pass }
    resp = server.post("/files", data)
    puts "Réponse POST status #{resp.status}, Content-Location: #{resp.headers["content-location"]}"
    puts "Body :"
    puts resp.body

  when "4"
    print "UUID : "
    uuid = gets.chomp
    print "Nouveau mot de passe : "
    new_pass = gets.chomp
    resp = server.patch("/files/#{uuid}", new_pass)
    puts resp.status == 204 ? "Mot de passe modifié !" : "Erreur #{resp.status} : #{resp.body}"

  when "5"
    print "UUID : "
    uuid = gets.chomp
    resp = server.delete("/files/#{uuid}")
    puts resp.status == 204 ? "Fichier supprimé !" : "Erreur #{resp.status} : #{resp.body}"

  when "6"
    print "Nom fichier 1 : "
    f1 = gets.chomp
    print "Nom fichier 2 : "
    f2 = gets.chomp
    resp = server.get("/blazediff/#{f1}/#{f2}")
    puts resp.status == 200 ? resp.body : "Erreur #{resp.status} : #{resp.body}"
  else
    puts "Option invalide"
  end
end
