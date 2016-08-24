##################
#  Version 1.3   #
#########################
# Added SportsRadar API #
#########################

require 'csv'
require 'json'
require './lib/nfl_helper'
require './lib/parse'

correct = 0
total = 0

periods_testing = ARGV.empty? ? 2 : ARGV[0].to_i

subgames = load_reference periods_testing
matches = load_testing periods_testing

print "Testing #{periods_testing} periods..."

matches.select { |m| !m.tie? }.each do |match|
  v_game1 = match.subgame1.search subgames.select { |g| g.name == match.subgame1.name }
  v_game2 = match.subgame2.search subgames.select { |g| g.name == match.subgame2.name }

  v_match = Match.new(v_game1, v_game2)
  
  v_match.tiebreaker! if v_match.tie?

  total += 1

  correct += 1 if v_match.winner.name == match.true_winner.name
end

clear_line

puts "Results: #{periods_testing} period(s), #{(100.0*correct/total).round(2)}% accurate (#{correct}/#{total})"
