require './app'
require 'sinatra/activerecord/rake'

namespace :db do 
    task :seed do
        seed_file = "./db/seeds.rb"
        puts "Seeding database from: #{seed_file}"
        load(seed_file) if File.exist?(seed_file)
    end
end