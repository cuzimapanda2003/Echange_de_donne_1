#pour run le programme: ruby /home/etd/EchangeDeDonne/cours2/tableau.rb

tableau = []
tableau = [1, "a", true, false, [1,2,3]]
print tableau.last

puts

puts tableau.size
puts tableau.first

tableau.each do |item|
    p item
end

]tableau << 4
tableau.push 9
tableau.select do |val|
val.is_a? Numeric

end
tableau.each do |item|
    p item
end

tab = [nom:"marc", age:"21", email:"marcblais03@..."]

tab.each do |item|
    p item
end


