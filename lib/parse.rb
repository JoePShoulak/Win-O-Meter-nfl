require 'json'
require 'csv'
require './lib/nfl_helper.rb'

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
      
  m = Match.new(subgame_home, subgame_away, true_winner)
    
  return m
end

def json_load(json_file, periods_testing)
  processed_games = []
  
  JSON.parse(File.read(json_file)).each do |game|
    processed_games << process(game, periods_testing)
  end
  
  return processed_games
end

if File.identical?(__FILE__, $0)
  print "Loading File..."
  matches = load JSON.parse File.read "./data/radar2015.json"
  print "\b"*30 + "File loaded" + "\n"
  puts "Total games loaded: #{matches.length}"
end
