#pour run le programme: ruby /home/etd/EchangeDeDonne/cours3/exercices.rb

#Une chaîne de caractères
def num1(text)
    print("votre texte : ")
    puts text
    nb_mots = text.count(" ")
    nb_lettre = text.count("a-zA-Z")

    puts "'#{text}' contient"

    puts "#{nb_mots + 1} mots et #{nb_lettre} lettres"

end

#num1("Je m'appelle James!")

#corriger num 1

def stats_text(text)
if text.is_a? String
        text.strip!
if text.empty?
        p "vide"

else 
    print("votre texte : ")
     puts text
     nb_mots = text.count(" ")
    nb_lettre = text.count("a-zA-Z")

    puts "'#{text}' contient"

     puts "#{nb_mots + 1} mots et #{nb_lettre} lettres"
end
else
    p "pas un string"
end

end
#stats_text("allo tout le monde")
#stats_text("    ")
#stats_text("")
#stats_text 42



#Th3 L33+0R

def num2(text)
puts "votre phrase: #{text}"
text.swapcase!
transformation =  {
 "A" => "@",
 "E" => "3",
 "S" => "$",
 "T" => '+'
}

  transformation.each do |lettre, remplacement|
    text.gsub!(lettre, remplacement)
  end


puts text
end

num2("Salut je m'appel James")
#num2(gets.chomp)

#un petit peu plus

def num3(tab)
sum = 0
puts "parametre = #{tab}"
tab.each do |item|
  if(item.is_a?(Integer) ||item.is_a?(Float)) 
        sum += item
  end
end
puts "the sum of the item is #{sum}"
end 


num3(p = ["a", 1, 4, 6.5, "3", true])

