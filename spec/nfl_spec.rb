# require 'spec_helper.rb'
require './lib/nfl_helper'
require './lib/parse'

describe "A Subgame" do 
  
  subgame = Subgame.new("Packers", 7, 200, 1)
    
  it "should have non-null values" do
    expect(subgame.name.length).to be > 0
    
    expect(subgame.points).to be >= 0
    expect(subgame.yards).to be >= 0
    expect(subgame.turns).to be >= 0
    
    expect(subgame.stats[0]).to be >= 0
    expect(subgame.stats[1]).to be >= 0
    expect(subgame.stats[2]).to be >= 0
    
    expect(subgame.info[0].length).to  be > 0
    expect(subgame.info[1]).to be >= 0
    expect(subgame.info[2]).to be >= 0
    expect(subgame.info[3]).to be >= 0
  end
  
  it "should have matching info and stats" do
    expect(subgame.stats[0]).to be == subgame.info[1]
    expect(subgame.stats[1]).to be == subgame.info[2]
    expect(subgame.stats[2]).to be == subgame.info[3]
  end
  
  it "should return 'false' for self.null?" do
    expect(subgame.null?).to be false
  end
  
  it "should be able to find the distance to a game" do
    game1 = Subgame.new("Packers", 10, 250, 2)

    expect(subgame.distance_to game1).to be > 0
  end
  
  it "should be able to find the closest game in a list (by algorithm)" do
    game1 = Subgame.new("Packers", 10, 250, 2)
    game2 = Subgame.new("Vikings", 14, 300, 3)
    
    games = [game1, game2]

    expect(subgame.distance_to(game1) < subgame.distance_to(game2)).to be true
    expect(subgame.search games).to be == game1
  end
end

describe "A Match," do
  
  subgame1 = Subgame.new("Home", 7, 200, 2)
  subgame2 = Subgame.new("Away", 10, 250, 1)
  match  = Match.new(subgame1, subgame2)
  
  context "when the scores are different," do
    it "should return self.tie? as false" do 
      expect(match.tie?).to be false
    end
    
    it "should have a winner and a loser, and they shouldn't be the same" do
      expect(match.subgames.include? match.winner).to be true
      expect(match.subgames.include? match.loser).to be true
      expect(match.winner).not_to be match.loser
    end
  end
  
  context "when the scores are the same," do
    it "should return self.tie? as true" do 
      match.subgame1.points = match.subgame2.points
      
      expect(match.tie?).to be true
    end
    
    it "should not have a winner or loser" do
      match.subgame1.points = match.subgame2.points

      expect(match.winner).to be nil
      expect(match.loser).to  be nil
    end
  
    it "should be able to change a score" do
      match.subgame1.points = match.subgame2.points
    
      old_points1 = match.subgame1.points
      old_points2 = match.subgame2.points
    
      match.tiebreaker!
    
      score_change = ((match.subgame1.points == old_points1 + 1) or (match.subgame2.points == old_points2 + 1))
    
      expect(match.winner).not_to be nil
      expect(match.winner.yards > match.loser.yards).to be true
      expect(score_change).to be true
    end
  end

end

describe "The Simulation," do 
  subgames1 = load_reference 1
  subgames3 = load_reference 3
  matches1 = load_testing 1
  matches3 = load_testing 3

  
  it "should be able to load a json file and process it into matches" do
    expect(matches1.length).to be > 0
    expect(matches1[0].class).to be Match
    expect(matches1[0].subgame1.class).to be Subgame
    expect(matches1[0].subgame2.class).to be Subgame
  end
  
  it "should be able to load a csv file and process it into subgames" do
    expect(subgames1.length).to be > 0
    expect(subgames1[0].class).to be Subgame
  end
  
  it "should have different stats for different period testing" do
    expect(subgames1[0].info).not_to be == subgames3[0].info
  end
end
