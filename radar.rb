require 'json'

year = 2013

print "Loading Schedule..."
print "\b"*30

begin
  schedule = JSON.parse(`curl -s http://api.sportradar.us/nfl-ot1/games/#{year}/REG/schedule.json?api_key=5etueuh9u3a8auueywb7pesw`)
rescue Exception => msg
  if msg.message.include? 'Developer Over Rate'
    puts "Too many queries this month"
    exit
  end
end

puts "Schedule loaded." + " "*20

game_ids = []

schedule["weeks"].each do |w|
  w["games"].each do |g|
    game_ids +=  [g["id"]]
  end
end

l = game_ids.length

games = []

l.times do |n|
  sleep 1
  print "Loading game #{n+1}/#{l} (#{(100*(n+1)/l).round}%)..."
  begin
    game = JSON.parse(`curl -s http://api.sportradar.us/nfl-ot1/games/#{game_ids[n]}/pbp.json?api_key=5etueuh9u3a8auueywb7pesw`)
  rescue Exception => msg
    if msg.message.include? 'Developer Over Rate'
      puts "Too many queries this month"
      exit
    else
      sleep 1
      game = JSON.parse(`curl -s http://api.sportradar.us/nfl-ot1/games/#{game_ids[n]}/pbp.json?api_key=5etueuh9u3a8auueywb7pesw`)
    end
  end
  print "\b"*30
  games += [game]
end

puts "Games loaded." + " "*20

f = File.open("./data/radar#{year}.json", "w")
f.write games.to_json
