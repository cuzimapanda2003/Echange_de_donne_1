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