puts "Are you sure you want to update files?"

response = gets.chomp!

old_algorithm = "nfl.rb"
new_algorithm = "nfl_test.rb"

old_lib = "lib/nfl_helper.rb"
new_lib = "lib/nfl_helper_test.rb"

if response == 'y' 
  
  system "cp #{new_algorithm} #{old_algorithm}"
  system "cp #{new_lib} #{old_lib}"
  
end