require 'dotenv'
Dotenv.load
require 'sinatra'
require "sinatra/config_file"
require 'haml'
require 'sinatra/activerecord'
require 'uri'
require './models/Task'
require 'omniauth'
require 'omniauth-google-oauth2'
require 'squeel'
require 'json'

config_file 'config.yml'

db = URI.parse(ENV['DATABASE_URL'])

ActiveRecord::Base.establish_connection(
  :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
  :host     => db.host,
  :port     => db.port,
  :username => db.user,
  :password => db.password,
  :database => db.path[1..-1],
  :encoding => 'utf8'
)

# Session:Cookie needed by OmniAuth
use Rack::Session::Cookie
enable :sessions

# MethodOverride for RESTful interface
use Rack::MethodOverride
# Use OmniAuth Google Strategy
use OmniAuth::Builder do
  provider :google_oauth2, ENV["GOOGLE_KEY"], ENV["GOOGLE_SECRET"],
    {
      :scope => "userinfo.email",
      #:prompt => "select_account",
      :image_aspect_ratio => "square",
      :image_size => 50
    }
end

before do 
  session[:served] ||= Array.new #Set session[:served] to a new array if needed
end

# Application API
get '/radness' do
  served = session[:served]
  # tasks = Task.where{-(id.like_any served)} # filter out already used tasks
  tasks = Task.all
  @Task = tasks[rand(tasks.count)];
  session[:served] << @Task.id
  content_type :json
  @Task.to_json
end

#index

get '/' do
  send_file File.join(settings.public_folder, 'index.html')
end

get '/submit' do
  send_file File.join(settings.public_folder, 'submit.html')
end


# Login/Logout stuff
get '/auth/google_oauth2/callback' do
    session[:auth] = request.env['omniauth.auth']
    redirect(request.env['omniauth.origin'], 303)
end

get '/logout' do 
    session.clear
    redirect('/')
end

get '/unauthorized' do 
    haml :unauthorized
end

def can_edit
    auth = session[:auth]
    redirect("/auth/google_oauth2?origin=#{URI.escape request.fullpath}") if auth.nil?
    settings.can_edit.include? auth[:info][:email]
end
