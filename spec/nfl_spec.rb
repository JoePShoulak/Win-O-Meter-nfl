require './lib/nfl_helper'

describe "A Subgame" do 
  
  subgame = Subgame.new("Packers", 7, 200, 1)
    
  it "should have a name" do
    expect(subgame.name.length).to be > 0
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
    expect(subgame.find_closest games).to be == game1
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
  end

end