#pour run le programme: ruby /home/etd/EchangeDeDonne/cours2/exercices.rb

def pair(nombre)

if !nombre.is_a?(Integer) || nombre.negative?
puts "Pas un entier positif"
else
if nombre % 2 == 0
puts "le nombre est pair"
puts "table de multiplication de 1 au nombre : "
0.upto(nombre - 1) do |i|
print("#{nombre} * #{i + 1} = ")
puts nombre * (i + 1)
end

else
puts "le nombre est impair"
puts "la table de multiplication du nombre a 1: "
nombre.downto(1) do |i|
print("#{nombre} * #{i} = ")
puts nombre * (i)
end
end
end
end

pair(3)
pair(4)

#nombre = Integer(gets.strip)
#pair(nombre)

#fin du num 1 pair_impair



