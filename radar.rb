require 'json'

if ARGV.empty?
  puts "Error: Needs a year"
  exit
end

year = ARGV[0]

print "Loading Schedule..."
print "\b"*30

begin
  schedule = JSON.parse(`curl -s http://api.sportradar.us/nfl-ot1/games/#{year}/REG/schedule.json?api_key=5etueuh9u3a8auueywb7pesw`)
rescue Exception => msg
  if msg.message.include? 'Developer Over Rate'
    puts "Error: Too many queries this month"
  else
    puts msg.message
  end
  exit
end

puts "Schedule loaded." + " "*20

game_ids = []

schedule["weeks"].each do |w|
  w["games"].each do |g|
    game_ids +=  [g["id"]]
  end
end

n = 1
l = game_ids.length

games = []

game_ids.each do |id|
  print "Loading game #{n}/#{l} (#{(100.0*n/l).round}%)..."
  n += 1
  begin
    game = JSON.parse(`curl -s http://api.sportradar.us/nfl-ot1/games/#{id}/pbp.json?api_key=5etueuh9u3a8auueywb7pesw`)
  rescue Exception => msg
    if msg.message.include? 'Developer Over Rate'
      puts "Error: Too many queries this month"
      exit
    elsif msg.message.include? 'Developer Over Qps'
      sleep 1
      game = JSON.parse(`curl -s http://api.sportradar.us/nfl-ot1/games/#{id}/pbp.json?api_key=5etueuh9u3a8auueywb7pesw`)
    else
      puts msg.message
      game = nil
    end
  end
  print "\b"*30
  games += [game]
end

games = games.select { |g| !g.nil? }

puts "Games loaded." + " "*20

f = File.open("./data/radar#{year}.json", "w")
f.write games.to_json
