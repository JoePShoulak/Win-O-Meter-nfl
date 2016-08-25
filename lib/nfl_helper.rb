require 'json'

# The algorithm
def algorithm(subgame1, subgame2) # Weighted Euclidean distance between two coordinates, dividing by the ratio of Std Dev from points and yards to turnovers (the min)
  l1 = subgame1.stats
  l2 = subgame2.stats
  dp = ( ( l1[0]-l2[0] )/8.0  )**2
  dy = ( ( l1[1]-l2[1] )/63.0 )**2
  dt = 0#(   l1[2]-l2[2]        )**2
  
  return (dp + dy + dt)**(0.5)
end

# Classes
class Subgame
  def initialize(name="", points=0, yards=0, turns=0, true_points=nil)
    @name   = name
    @points = points.to_i
    @yards  = yards.to_i
    @turns  = turns.to_i
    @true_points  = true_points.to_i
  end
  
  attr_accessor :name, :points, :yards, :turns, :true_points
  
  def stats
    return @points, @yards, @turns
  end
  
  def info
    return [@name] + self.stats
  end
  
  def distance_to(game)
    return algorithm(self, game)
  end
  
  def search(list_of_games)
    return list_of_games.sort_by { |g| algorithm(self, g) }[0]
  end
  
end

class Match
  def initialize(subgame1, subgame2, true_winner=nil, true_tie=nil)
    @subgame1 = subgame1
    @subgame2 = subgame2
    @true_winner = true_winner
    @true_tie = true_tie
  end
  
  attr_reader :subgame1, :subgame2, :true_winner, :true_tie
  
  def subgames
    return [@subgame1, @subgame2]
  end
  
  def tie?
    self.subgame1.points == self.subgame2.points
  end
  
  def winner
    return self.tie? ? nil : self.subgames.max_by { |g| g.points }
  end
  
  def loser
    return self.tie? ? nil : self.subgames.min_by { |g| g.points }
  end
  def info
    return self.subgame1.info + self.subgame2.info
  end
  
  def tiebreaker!    
    self.subgames.sort_by { |g| g.yards }[1].points += 1
  end
end

# Misc.
def clear_line
  print "\r" + " "*100 + "\b"*100
end

# Parse game
def process(game, periods_testing)
  home = game["summary"]["home"]["name"]
  away = game["summary"]["away"]["name"]
  
  home_yards = 0
  away_yards = 0
  
  home_score = 0
  away_score = 0
  
  true_score_home = 0
  true_score_away = 0
    
  game["periods"].length.times do |pe|
    period = game["periods"][pe]
    home_points = period["scoring"]["home"]["points"].to_i
    away_points = period["scoring"]["away"]["points"].to_i
    
    home_score += home_points unless pe >= periods_testing
    away_score += away_points unless pe >= periods_testing
    
    true_score_home += home_points
    true_score_away += away_points
    
    period["pbp"].select { |pl| pl["type"] == "drive" }.each do |play|# for each play do 
      unless pe >= periods_testing
        unless play["events"].nil?
          play["events"].select { |e| ["rush", "pass"].include? e["play_type"] }.each do |event|
            unless event["statistics"].nil?
              event["statistics"].select { |s| ["rush", "pass"].include? s["stat_type"]}.each do |s|
                case s["team"]["name"]
                when home
                  home_yards += s["yards"].to_i 
                when away
                  away_yards += s["yards"].to_i
                end
              end
            end
          end
        end
      end
    end
  end
  
  subgame_home = Subgame.new(game["summary"]["home"]["market"] + " " + home, home_score, home_yards, 0, true_score_home)
  subgame_away = Subgame.new(game["summary"]["away"]["market"] + " " + away, away_score, away_yards, 0, true_score_away)
  
  true_winner = [subgame_home, subgame_away].sort_by { |s| s.true_points }[1]
  is_a_tie = ( subgame_home.true_points == subgame_away.true_points )
  
  m = Match.new(subgame_home, subgame_away, true_winner, is_a_tie)
    
  return m
end

# Parse season
def json_load(json_file, periods_testing)
  processed_games = []

  JSON.parse(File.read(json_file)).each do |game|
    processed_games << process(game, periods_testing)
  end
  
  return processed_games
end

# Load files
def load_reference(periods_testing)
  print "Loading Reference File (1/2)..."
  subgames  = json_load("./data/radar2014.json", periods_testing).map {|m| [m.subgame1, m.subgame2]}.flatten
  clear_line
  print "Loading Reference File (2/2)..."
  subgames += json_load("./data/radar2013.json", periods_testing).map {|m| [m.subgame1, m.subgame2]}.flatten
  clear_line
  
  return subgames
end

def load_testing(periods_testing)
  print "Loading Testing File..."
  matches = json_load("./data/radar2015.json", periods_testing)
  clear_line
  
  return matches
end
