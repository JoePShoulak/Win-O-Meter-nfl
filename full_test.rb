require './nfl'

puts "Executing full test:"

system "rspec"

(1..4).each do |n|
  simulate n
end