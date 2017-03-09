=begin

This script lets you hunt specific numbers when playing. It's perfect
for any game of type "hit any number that is less than N" or "hit N".

The script places new bets in a loop, all with the same amount and
win chance. Once a bet that meets the criteria is found, the loop stops.

The script requires the following permissions API:

* play

=end

require 'pp'
require 'yolodice_client'

YD_API_KEY = 'paste_your_api_key_here'

# Below is a set of bet parameters. You can change any of them.
bet_amount = 100   # amount of the bet, in satoshis
bet_range = 'lo'   # 'lo' or 'hi'

# Bet target. You can either set target directly or calculate target
# from win chance or multiplier. Just comment/uncomment any piece of code.
#
# Unless rules of the number hunt competition specify otherwise, bet range
# (multiplier/chance) can be anything.

# Explicit target: 
bet_target = 495000

# Target from chance. NOTE: chance is probability of winning, ranges from 0 to 1.
# Probability of 0.5 = 50%
# bet_target = YolodiceClient.target_from_probability(0.5)

# Target from multiplier.
# bet_target = YolodiceClient.target_from_multiplier(2)


# Connect and authenticate

yd = YolodiceClient.new
yd.connect
user = yd.authenticate YD_API_KEY
puts "You authenticated as user #{user['name']}(#{user['id']})"

puts 'Rolling now.'
total_profit = 0
loop do
  b = yd.create_bet attrs: {amount: bet_amount, range: bet_range, target: bet_target}, include_datas: true

  total_profit += b['profit']

  # Each printed + is a winning bet, each . is a losing bet
  print b['win'] ? '+' : '.'

  # Alternatively, print bet details. Comment this out if you don't need it.
  puts "bet_id: #{b['id']}, amount: #{'%12.8f' % YolodiceClient.satoshi_to_btc(b['amount'])}, profit: #{'%12.8f' % YolodiceClient.satoshi_to_btc(b['profit'])}, series profit: #{'%12.8f' % YolodiceClient.satoshi_to_btc(total_profit)}, balance: #{'%12.8f' % YolodiceClient.satoshi_to_btc(b['user_data']['balance'])}"

  # Check if rolled number condition is met. You can change the condition as you want.
  # if b['rolled'] == 777777
  if b['rolled'] <= 10
    print "\n"
    puts "Congratulations, you found a winning bet!"
    pp b
    break;
  end
end
