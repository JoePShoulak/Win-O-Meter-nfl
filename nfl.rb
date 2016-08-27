require './lib/nfl_helper'

def simulate(periods_testing, verbose)
  total   = 0
  correct = 0
  unknown = 0

  matches  = load_testing   periods_testing

  matches.select { |m| !m.true_tie }.each do |match|
    total += 1
    
    if !match.tie? && !match.true_tie
      correct += 1 if match.winner.name == match.true_winner.name
      
      if verbose
        puts "#{match.subgame1.name}:"
        puts "\tCheck Score: #{match.subgame1.points}"
        puts "\tFinal Score: #{match.subgame1.final_score}"

        puts "#{match.subgame2.name}:"
        puts "\tCheck Score: #{match.subgame2.points}"
        puts "\tFinal Score: #{match.subgame2.final_score}"
        
        spread = match.winner.points - match.loser.points
        win_percent = ( 100*( 0.5 + (spread/40.0) ) ).round(2)
        
        puts "Prediction: "
        puts "\t#{match.winner.name} is ahead by #{spread}"
        puts "\t#{match.winner.name}: #{win_percent}%"
        puts "\t#{match.loser.name}: #{100 - win_percent}%"
        
        puts "Result: #{match.winner.name == match.true_winner.name}"
        puts 
      end
    else
      unknown += 1
    end
  end

  clear_line  
  
  correct_ratio = correct.to_f/total
  unknown_ratio = unknown.to_f/total
  theoretical_ratio = correct.to_f/(total - unknown)
  
  correct_percent = 100*correct_ratio.round(2)
  unknown_percent = 100*unknown_ratio.round(2)
  theoretical_percent = 100*theoretical_ratio.round(2)
  
  message = "Results: #{periods_testing} period(s), #{correct_percent}% accurate, #{unknown_percent}% unknown, #{theoretical_percent}% theoretical."
  numbers = [correct_percent, unknown_percent, theoretical_percent]

  return [message] + numbers
end

if __FILE__ == $0
  if ARGV.empty?
    puts "Error: Needs number of periods of use in testing"
    exit
  end
  
  if ARGV[1] == "verbose"
    verbose = true
  else
    verbose = false
  end
  
  if ARGV[0] == "all"
    correct = 0
    unknown = 0
    theoretical = 0
    (1..3).each do |n|
      r = simulate(n, verbose)
      puts r[0]
      correct += r[1]
      unknown += r[2]
      theoretical += r[3]
    end
    puts "Average Correct: #{(correct/3).round(2)}%"
    puts "Average Unknown: #{(unknown/3).round(2)}%"
    puts "Average Theoretical: #{(theoretical/3).round(2)}%"
  else
    simulate ARGV[0].to_i
  end
end
