###################
#   NFL Lib v1.3  #
###############################
#                             #
###############################

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
  
  def null?
    return ( (self.name == "") and (self.points + self.yards + self.turns == 0) )
  end
  
  def distance_to(game)
    return algorithm(self, game)
  end
  
  def search(list_of_games)
    return list_of_games.sort_by { |g| algorithm(self, g) }[0]
  end
  
end

class Match
  def initialize(subgame1, subgame2, true_winner=nil)
    @subgame1 = subgame1
    @subgame2 = subgame2
    @true_winner = true_winner
  end
  
  attr_reader :subgame1, :subgame2, :true_winner
  
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

def algorithm(subgame1, subgame2) # Weighted Euclidean distance between two coordinates, dividing by the ratio of Std Dev from points and yards to turnovers (the min)
  l1 = subgame1.stats
  l2 = subgame2.stats
  dp = ( ( l1[0]-l2[0] )/8.0  )**2
  dy = ( ( l1[1]-l2[1] )/63.0 )**2
  dt = 0#(   l1[2]-l2[2]        )**2
  
  return (dp + dy + dt)**(0.5)
end

def clear_line
  print "\r" + " "*100 + "\b"*100
end

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
