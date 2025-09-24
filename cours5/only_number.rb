#pour run le programme: ruby /home/etd/EchangeDeDonne/cours5/only_number.rb

def num(tab)
    unless tab.is_a? Array
        puts "la valeur n'est pas un tableau"
        return
    end

    puts "saisie : #{tab}"

 nombre = tab.flat_map { |element| element.scan(/\d+/) }

    p  nombre.join(" | ")





end


 require_relative 'input'