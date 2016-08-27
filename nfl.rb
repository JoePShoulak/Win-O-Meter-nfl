require './lib/nfl_helper'

def simulate(periods_testing)
  total   = 0
  correct = 0
  unknown = 0

  matches  = load_testing   periods_testing

  matches.select { |m| !m.true_tie }.each do |match|
    total += 1
    
    if !match.tie? && !match.true_tie
      correct += 1 if match.winner.name == match.true_winner.name
    else
      unknown += 1
    end
  end

  clear_line  
  
  message = "Results: #{periods_testing} period(s), #{(100.0*correct/total).round(2)}% accurate (#{correct}/#{total}), #{(100.0*unknown/total).round(2)}% unknown (#{unknown}/#{total})"
  numbers = [(100.0*correct/total).round(2), (100.0*unknown/total).round(2)]

  return [message] + numbers
end

if __FILE__ == $0
  if ARGV.empty?
    puts "Error: Needs number of periods of use in testing"
    exit
  end
  
  case ARGV[0]
  when "all"
    correct = 0
    unknown = 0
    (1..3).each do |n|
      r = simulate n
      puts r[0]
      correct += r[1]
      unknown += r[2]
    end
    puts "Average Correct: #{(correct/3).round(2)}%"
    puts "Average Unknown: #{(unknown/3).round(2)}%"
  when "test"
    system "rspec"
    correct = 0
    unknown = 0
    (1..3).each do |n|
      r = simulate n
      puts r[0]      
      correct += r[1]
      unknown += r[2]
    end
    puts "Average Correct: #{(correct/3).round(2)}%"
    puts "Average Unknown: #{(unknown/3).round(2)}%"
  else
    simulate ARGV[0].to_i
  end
end
