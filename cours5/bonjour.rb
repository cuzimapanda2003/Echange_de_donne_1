#pour run le programme: ruby /home/etd/EchangeDeDonne/cours5/bonjour.rb


def num(nom, prenom, anne)
    y = Time.now.year
    age = y - anne

    puts "Bonjour "+ prenom.capitalize + " " + nom.capitalize + ", vous avez #{age} ans."
    print "vous êtes "

    if(age < 25)
            puts "jeune!"
    elsif(age >=25 && age <50)
        puts "plus tout jeune!"
    elsif(age >= 50 && age < 75)
        puts "viellissant!"
    else
        puts "vieux!"
    end




end 


num("blais","marc",1900)



