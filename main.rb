require 'sinatra'
require 'sinatra/reloader' if development?
require 'erb'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'FvFRCS44N26EfeCALAhc'

set :sessions, true

get '/' do
  if session[:name]
  redirect '/game'
  else
  redirect '/new_game'
  end
end

get '/new_game' do
  session[:card_path] = "/images/cards/"
  files = Dir.entries("public/images/cards/")

  card_files = []
  values = []

  files.each { |file| card_files << file if file.include? "jpg"}
  card_files.delete_if { |file| file.include? "cover" or file.include? "joker"}
  session[:card_files] = card_files.shuffle!

  card_files.each do |card|
    if card.include? 'ace'
      values << 11
    elsif card.include? 'jack'
      values << 10
    elsif card.include? 'queen'
      values << 10
    elsif card.include? 'king'
      values << 10
    else card.each_char do |e|
      if e.to_i == 1
        values << 10
      elsif e.to_i != 0 && e.to_i != 1
        values << e.to_i
      else
        values << nil
      end
    end
  end
  end

  values.compact!

  session[:deck] = Hash[card_files.zip values]
  session[:dealer_cards] = []
  session[:player_cards] = []
  session[:dealer_cards] << session[:card_files].shift
  session[:dealer_cards] << session[:card_files].shift
  session[:player_cards] << session[:card_files].shift
  session[:player_cards] << session[:card_files].shift

  def calculate(cards, deck)
    total = 0
    cards.each { |card| total += deck[card]}
    cards.select { |e| e.include? 'ace'}.count.times {total -= 10 if total > 21}
    total
  end

  session[:dealer_total] = calculate(session[:dealer_cards], session[:deck])
  session[:player_total] = calculate(session[:player_cards], session[:deck])

  session[:total_amount] = 500.to_i

  erb :new_game
end

get ('/bet') { erb :bet }

post '/bet' do
  if params[:bet_amount].nil? || params[:bet_amount].to_i == 0
    @error = "You must make a bet."
    halt erb(:bet)
  elsif params[:bet_amount].to_i > session[:total_amount]
    @error  = "Bet amount cannot exceed what you have: $#{session[:total_amount]}."
    halt erb(:bet)
  else
    session[:bet_amount] = params[:bet_amount].to_i
    redirect '/game'
  end
end

get ('/game') { erb :game }

post '/game' do
  session[:bet_amount] = params[:bet_amount].to_i
  card_files = []
  values = []
  files = Dir.entries("public/images/cards/")
  files.each { |file| card_files << file if file.include? "jpg"}
  card_files.delete_if { |file| file.include? "cover" or file.include? "joker"}
  session[:card_files] = card_files.shuffle!

  card_files.each do |card|
    if card.include? 'ace'
      values << 11
    elsif card.include? 'jack'
      values << 10
    elsif card.include? 'queen'
      values << 10
    elsif card.include? 'king'
      values << 10
    else card.each_char do |e|
      if e.to_i == 1
        values << 10
      elsif e.to_i != 0 && e.to_i != 1
        values << e.to_i
      else
        values << nil
      end
    end
  end
  end

  def calculate(cards, deck)
    total = 0
    cards.each { |card| total += deck[card]}
    cards.select { |e| e.include? 'ace'}.count.times {total -= 10 if total > 21}
    total
  end

  session[:dealer_cards] = []
  session[:player_cards] = []
  session[:dealer_cards] << session[:card_files].shift
  session[:dealer_cards] << session[:card_files].shift
  session[:player_cards] << session[:card_files].shift
  session[:player_cards] << session[:card_files].shift
  session[:dealer_total] = calculate(session[:dealer_cards], session[:deck])
  session[:player_total] = calculate(session[:player_cards], session[:deck])
  erb :game
end

post '/game/player_hit' do
  def calculate(cards, deck)
    total = 0
    cards.each { |card| total += deck[card]}
    cards.select { |e| e.include? 'ace'}.count.times {total -= 10 if total > 21}
    total
  end
  session[:player_cards] << session[:card_files].shift
  session[:player_total] = calculate(session[:player_cards], session[:deck])
  erb :game
end

post ('/game/player_stay') { erb :game_stay }

post '/game/dealer_hit' do
  session[:dealer_cards] << session[:card_files].shift
  session[:dealer_total] = calculate(session[:dealer_cards], session[:deck])
  erb :game_stay
end

get ('/game_over'){ erb :game_over }

not_found { erb :not_found }