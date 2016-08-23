require 'json'
require 'csv'
require './lib/nfl_helper_test.rb'

$test = true

def process(game)
  home = game["summary"]["home"]["name"]
  away = game["summary"]["away"]["name"]
  
  home_yards = 0
  away_yards = 0
  
  home_score = 0
  away_score = 0
  
  game["periods"].each do |period|
    home_score += period["scoring"]["home"]["points"].to_i
    away_score += period["scoring"]["away"]["points"].to_i
    
    period["pbp"].select { |p| p["type"] == "drive" }.each do |play|# for each play do 
      
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
  
  subgame_home = Subgame.new(game["summary"]["home"]["market"] + " " + home, home_score, home_yards, 0)
  subgame_away = Subgame.new(game["summary"]["away"]["market"] + " " + away, away_score, away_yards, 0)
  
  m = Match.new(subgame_home, subgame_away)
  
  return m
end

def json_load(json_file)
  processed_games = []
  
  JSON.parse(File.read(json_file)).each do |game|
    processed_games << process(game)
  end
  
  return processed_games
end

def csv_load(csv_file)
  processed_games = []
  
  CSV.read(csv_file).each do |line|
    processed_games << Subgame.new(line[3], line[7], line[9],  line[10]) # winning team (team 1)
    processed_games << Subgame.new(line[5], line[8], line[11], line[12]) # losing team (team 2)
  end
  
  return processed_games
end

if File.identical?(__FILE__, $0)
  print "Loading File..."
  matches = load JSON.parse File.read "./data/radar2015.json"
  print "\b"*30 + "File loaded" + "\n"
  puts "Total games loaded: #{matches.length}"
end
