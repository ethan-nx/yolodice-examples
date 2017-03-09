=begin

This script implements a simple Martingale strategy:
https://en.wikipedia.org/wiki/Martingale_(betting_system)

* It always places bets with x2 multiplier.
* It starts with a base bet amount.
* On each loss it multiplies the bet base by two.
* On each win it sets bet amount back to base.

The script places new bets in a loop. You can uncomment any of the stop
conditions or implement a new one.

A few ideas what you can do with this script:

* change base amount
* implement another stop condition

The script requires the following permissions API:

* play

=end

require 'pp'
require 'yolodice_client'

YD_API_KEY = 'paste_your_api_key_here'

# Below is a set of bet parameters. You can change any of them.
bet_base_amount = 100   # base amount of the bet, in satoshis
bet_range = 'lo'        # 'lo' or 'hi'

bet_target = 494999     # it corresponds to multiplier x2


# Connect and authenticate

yd = YolodiceClient.new
yd.connect
user = yd.authenticate YD_API_KEY
puts "You authenticated as user #{user['name']}(#{user['id']})"

puts 'Rolling now.'

total_profit = 0        # this total profit will update with each bet. it's in satoshis.

bet_amount = bet_base_amount
loop do
  b = yd.create_bet attrs: {amount: bet_amount, range: bet_range, target: bet_target}, include_datas: true

  total_profit += b['profit']

  # Each printed + is a winning bet, each . is a losing bet
  print b['win'] ? '+' : '.'

  # Alternatively, print bet details. Comment this out if you don't need it.
  puts "bet_id: #{b['id']}, amount: #{'%12.8f' % YolodiceClient.satoshi_to_btc(b['amount'])}, profit: #{'%12.8f' % YolodiceClient.satoshi_to_btc(b['profit'])}, series profit: #{'%12.8f' % YolodiceClient.satoshi_to_btc(total_profit)}, balance: #{'%12.8f' % YolodiceClient.satoshi_to_btc(b['user_data']['balance'])}"

  # If the bet wins, go back to base. If it loses, multiply amount by 2.
  if b['win']
    # this bet is a winnig bet
    bet_amount = bet_base_amount
  else
    # this is a losing bet
    bet_amount *= 2
  end

  # Stop condition
  if total_profit > 100000
    break;
  end
end
