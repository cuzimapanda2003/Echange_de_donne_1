# commentaire
#pour run le programme: ruby /home/etd/EchangeDeDonne/cours1/code.rb

une_variable = 12

mon_nom = "marc"

PI = 3.1415926537

PI = 3

puts mon_nom
p mon_nom
# pour test dans le terminal type irb (bac a sable zone test)

def greet(name)
    puts "coucou #{name}"
end
greet "marc"

puts "7" * 7
puts "7".to_i * 7


# demander un nom
name = gets
puts name
puts name.upcase
puts name.upcase.reverse
name = name.upcase
puts name
#le ! permet ed changer la valuer de nom sans faire name =...
name.downcase!
puts name


3.times do
    puts "a"
end

3.times do |i|
    puts i
end

3.downto(0) do |i|
    puts i
end




