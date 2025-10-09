#ruby /home/etd/EchangeDeDonne/laboratoire/console.rb
def big_mac_menu
    loop do
  puts "Taskor"
  puts "-" * 7
  print "Liste ou Ajout (L, A): "
  choix = STDIN.gets.chomp.strip.upcase
  case choix
  when "A"
    print "Nom de la tache : "
    nom = STDIN.gets.chomp.strip
    if nom.empty?
      puts " Le nom ne peut pas etre vide."
    else
      require "net/http"
      require "json"
      uri = URI("http://localhost:1234/new-task")
      req = Net::HTTP::Post.new(uri, "Content-Type" => "application/json")
      req.body = { name: nom }.to_json
      begin
        res = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }
        if res.is_a?(Net::HTTPSuccess)
          puts " Tache ajoutee avec succes !"
        else
          puts " Erreur (#{res.code}): #{res.body}"
        end
      rescue => e
        puts " Erreur de connexion au serveur : #{e.message}"
      end
    end
  when "L"
    puts "En développement 2"
  else
    puts "Choix invalide."
  end
end
end

big_mac_menu