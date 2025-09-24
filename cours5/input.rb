saisies = []

loop do 

    print "valeur?"
    saisie = gets.strip
    saisies << saisie.to_s

    break if saisie.empty?

end 

num(saisies)

