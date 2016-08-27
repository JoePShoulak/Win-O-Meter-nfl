require './lib/nfl_helper'

def simulate(periods_testing)
  correct = 0
  total   = 0

  subgames = load_reference periods_testing
  matches  = load_testing   periods_testing

  matches.select { |m| !m.true_tie }.each do |match|
    total += 1
  
    v_game1 = match.subgame1.find_closest subgames.select { |g| g.name == match.subgame1.name }
    v_game2 = match.subgame2.find_closest subgames.select { |g| g.name == match.subgame2.name }

    v_match = Match.new(v_game1, v_game2)
  
    v_match.tiebreaker! if v_match.tie?

    correct += 1 if v_match.winner.name == match.true_winner.name
  end

  clear_line
  
  plural = (periods_testing == 1 ? ", " : "s,")

  return "Results: #{periods_testing} period" + plural + " #{(100.0*correct/total).round(2)}% accurate (#{correct}/#{total})", (100.0*correct/total).round(2)
end

if __FILE__ == $0
  if ARGV.empty?
    puts "Error: Needs number of periods of use in testing"
    exit
  end
  
  case ARGV[0]
  when "all"
    total = 0
    (1..3).each do |n|
      r = simulate n
      puts r[0]
      total += r[1]
    end
    puts "Average: #{(total/3).round(2)}%"
  when "test"
    system "rspec"
    total = 0
    (1..3).each do |n|
      r = simulate n
      puts r[0]
      total += r[1]
    end
    puts "Average: #{(total/3).round(2)}%"
  else
    simulate ARGV[0].to_i
  end
end
