
#pour run le programme: ruby /home/etd/EchangeDeDonne/cours4/petitplus.rb

def num3(tab)
    unless tab.is_a? Array
        puts "la valeur n'est pas un tableau"
        return
    end
sum = 0
puts "parametre = #{tab}"
tab.each do |item|
  if(item.is_a?(Integer) ||item.is_a?(Float)) 
        sum += item
  end
end
puts "the sum of the item is #{sum}"
end 


num3 ["a", 1, 4, 6.5, "3", true]
num3 3
num3 "patate"


saisies = []

loop do 

    print "valeur?"
    saisie = gets.strip
    saisies << saisie.to_f

    break if saisie.empty?

end 

num3 saisies