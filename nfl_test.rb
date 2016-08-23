##################
#  Version 1.3   #
#########################
# Added SportsRadar API #
#########################

require 'csv'
require 'json'
require './lib/nfl_helper_test'
require './lib/parse'

correct = 0
total = 0

matches = json_load "./data/radar2015.json"
#subgames = csv_load("./data/ref5year.csv")
subgames = json_load("./data/radar2014.json").map {|m| [m.subgame1, m.subgame2]}.flatten

matches.each do |match|
  v_game1 = match.subgame1.search subgames.select { |g| g.name == match.subgame1.name }
  v_game2 = match.subgame2.search subgames.select { |g| g.name == match.subgame2.name }
  
  v_match = Match.new(v_game1, v_game2)
    
  v_match.tiebreaker! if v_match.winner == nil
  
  total += 1
  correct += 1 if v_match.winner.name == match.winner.name
end

puts "Correct: #{correct} (#{(100.0*correct/total).round(2)}%)"
puts "Total:   #{total}"