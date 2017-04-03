=begin

This simple script just places bets. It can be used as a base for
more advanced scripts.

I recommend you to copy this script and adapt to your needs.

The script requires the following permissions API:

* play

=end

require 'pp'
require 'yolodice_client'

YD_API_KEY = ENV['YD_API_KEY'] || 'paste_your_api_key_here'

# Below is a set of bet parameters. You can change any of them.
bet_amount = 100   # amount of the bet, in satoshis
bet_range = 'lo'   # 'lo' or 'hi'

# Bet target. You can either set target directly or calculate target
# from win chance or multiplier. Just comment/uncomment any piece of code.

# Explicit target: 
bet_target = 495000

# Target from chance. NOTE: chance is probability of winning, ranges from 0 to 1.
# Probability of 0.5 = 50%
# bet_target = YolodiceClient.target_from_probability(0.5)

# Target from multiplier.
# bet_target = YolodiceClient.target_from_multiplier(2)

# Bet limit. Set it to the number of bets you want to roll. Set to false for no limit.
# bet_limit = false
bet_limit= 10

# Connect and authenticate

yd = YolodiceClient.new
yd.connect
user = yd.authenticate YD_API_KEY
puts "You authenticated as user #{user['name']}(#{user['id']})"

puts 'Rolling now.'
total_profit = 0
bet_count = 0

loop do
  b = yd.create_bet attrs: {amount: bet_amount, range: bet_range, target: bet_target}, include_datas: true

  total_profit += b['profit']

  # Each printed + is a winning bet, each . is a losing bet
  print b['win'] ? '+' : '.'

  # Alternatively, print bet details. Comment this out if you don't need it.
  puts "bet_id: #{b['id']}, amount: #{'%12.8f' % YolodiceClient.satoshi_to_btc(b['amount'])}, profit: #{'%12.8f' % YolodiceClient.satoshi_to_btc(b['profit'])}, series profit: #{'%12.8f' % YolodiceClient.satoshi_to_btc(total_profit)}, balance: #{'%12.8f' % YolodiceClient.satoshi_to_btc(b['user_data']['balance'])}"

  bet_count += 1

  # Break limit
  if bet_count && bet_count >= bet_limit
    print "\n"
    puts "Bet limit #{bet_limit} reached. Exiting."
    break
  end

end
