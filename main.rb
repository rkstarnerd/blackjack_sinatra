require 'sinatra'
require 'sinatra/reloader' if development?
require 'erb'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'FvFRCS44N26EfeCALAhc'

set :sessions, true

get ('/') { redirect '/new_game' }

get ('/new_game') { erb :new_game }

post '/bet' do
  @name = params[:name].capitalize
  erb :bet
end

get ('/bet') { erb :bet }

post '/game' do
  @bet_amount = params[:bet_amount]
  erb :game
end

not_found { erb :not_found }