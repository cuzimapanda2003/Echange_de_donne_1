#Marc-Antoine Blais
#ruby /home/etd/EchangeDeDonne/laboratoire/labo01.rb
require_relative 'cryptor'


def encoder()
    print "Contenu à encoder: "
    msg = gets.chomp

    print "Clé: "
    key = gets.chomp.to_i

    crypto = Cryptor.new(key)

    secret = ""
    msg.each_char do |char|
    code = crypto.encode(char.ord)
    secret << code.chr
    end


    puts "Secret = #{secret}"
end

def decoder()
    print "Contenu à décoder: "
    msg = gets.chomp

    print "Clé: "
    key = gets.chomp.to_i

    crypto = Cryptor.new(key)

    message = ""
    msg.each_char do |char|
    code = crypto.decode(char.ord)
    message << code.chr
end


    puts "Message = #{message}"
end

def menu()
    choice = ""
    while(choice != "q" && choice != "Q")
        print "Appuyer sur 'd' pour décoder, 'e' pour encoder ou 'q' pour quitter: "
        choice = gets.chomp
        if(choice == "d" || choice == "D")
            decoder
        elsif(choice == "e" || choice == "E")
            encoder
        end
    end


end

menu