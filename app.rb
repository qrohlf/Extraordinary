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
require "net/https"

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
use Rack::Session::Cookie, :expire_after => 1209600, # 7 days
                           :secret => ENV['COOKIE_SECRET']

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

  if served.count == 0
    tasks = Task.where{(status == 'rad')}
    @Task = tasks[rand(tasks.count)];
  elsif served.count == 2
    @Task = Task.new(id: -1, task: "Were the first two suggestions really that bad?", deadline: "Hopefully the next one will be spot-on.")
  elsif served.count == 6
    @Task = Task.new(id: -1, task: "Look, we can't help but think that you're not really taking this seriously.", deadline: "Pressing buttons is not a fulfilling way of life.")
  else
    tasks = Task.where{(id.not_eq_all served) & (status == 'rad')} # filter out already used tasks
    @Task = tasks[rand(tasks.count)]
  end

  if @Task == nil 
    @Task = Task.new(id: -2, task: "Nothing sounded interesting? Fulfilling? We're all out of ideas.", deadline: "<a href='/submit'>Maybe you can give us some new ones.</a>")
  end

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

post '/submit' do 
  Task.create(params)
  notify("New task submitted: '#{params[:task]} -- #{params[:deadline]}'")
  'success'
end


# Login/Logout stuff
get '/auth/google_oauth2/callback' do
    session[:auth] = request.env['omniauth.auth']
    redirect(request.env['omniauth.origin'], 303)
end

get '/logout' do 
    session[:auth] = nil;
    session[:served] = Array.new;
    redirect('/')
    return nil
end

get '/unauthorized' do 
    haml :unauthorized
end

get '/moderate' do
  can_edit
  @title = 'moderation'
  if params[:showall] == 'true'
    @showall = true
    @tasks = Task.all.order(created_at: :desc)
  else 
    @tasks = Task.where(status: 'needs_moderation').order(created_at: :desc)
  end
  haml :moderate, layout_engine: :erb
end

def can_edit
    auth = session[:auth]
    redirect("/auth/google_oauth2?origin=#{URI.escape request.fullpath}") if auth.nil?
    settings.can_edit.include? auth[:info][:email]
end

def notify(message) 
  url = URI.parse("https://api.pushover.net/1/messages.json")
  req = Net::HTTP::Post.new(url.path)
  req.set_form_data({
    :token => ENV['PUSHOVER_TOKEN'],
    :user => ENV['PUSHOVER_USER'],
    :message => message,
  })
  res = Net::HTTP.new(url.host, url.port)
  res.use_ssl = true
  res.verify_mode = OpenSSL::SSL::VERIFY_PEER
  res.start {|http| http.request(req) }
end
