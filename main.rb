require 'sinatra'
require 'sinatra/reloader' if development?

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'your_secret' # change 'your_secret to some random string'

set :sessions, true

get '/' do
  redirect '/new_game'
end

get '/new_game' do
  erb :new_game
end

post '/bet' do
  @name = params[:name]
  erb :bet
end

get '/bet' do
  erb :bet
end

post '/game' do
  erb :game
end

not_found do
  erb :not_found
end