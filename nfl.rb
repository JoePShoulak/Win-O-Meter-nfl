##################
#  Version 1.3   #
#########################
# Added SportsRadar API #
#########################

require './lib/nfl_helper'

def simulate(periods_testing=nil)
  correct = 0
  total = 0

  if periods_testing.nil?
    periods_testing = ARGV.empty? ? 2 : ARGV[0].to_i
  end

  subgames = load_reference periods_testing
  matches = load_testing periods_testing

  matches.select { |m| !m.true_tie }.each do |match|
    total += 1
  
    v_game1 = match.subgame1.search subgames.select { |g| g.name == match.subgame1.name }
    v_game2 = match.subgame2.search subgames.select { |g| g.name == match.subgame2.name }

    v_match = Match.new(v_game1, v_game2)
  
    v_match.tiebreaker! if v_match.tie?

    correct += 1 if v_match.winner.name == match.true_winner.name
  end

  clear_line

  puts "Results: #{periods_testing} period(s), #{(100.0*correct/total).round(2)}% accurate (#{correct}/#{total})"
end

if __FILE__ == $0
  simulate
end
