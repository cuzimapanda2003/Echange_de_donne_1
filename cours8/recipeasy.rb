require "bundler/inline"

gemfile do
    source "http://rubygems.org"

    gem "sinatra-contrib"
    gem "rackup"
    gem "puma"
end

require "sinatra/base"
require "sinatra/reloader"

RECIPES_FILE = File.join __dir__, "recipes.json"

unless File.exists? RECIPES_FILE 
File.write RECIPES_FILE, "[]"
end

def save_recipes
  File.write(RECIPES_FILE, @recipes.to_json)
end


class SimpleAuth < Sinatra::Base

    set :bind, "0.0.0.0"
    set :port, "5678"

    configure :development do
        register Sinatra::Reloader
    end

    def get_recipes 
        return JSON.parse File.read(RECIPES_FILE), symbolize_names: true rescue []
    end

    before {
        @recipes = get_recipes
    }

    

post "/recipes" do 
  recipe_params = JSON.parse request.body.read, symbolize_names: true rescue {}

  name = recipe_params[:name]

  if name.nil? || name.strip.empty?
    status 404
    headers({"Content-Type"=>"Text/plain"})
    return "Nom requis..."
  end

  new_recipe = {
    name: name
  }

  @recipes << new_recipe

  File.write(RECIPES_FILE, @recipes.to_json)

  status 201
end

get "/recipes" do 
  sort = params[:sort]

  if sort == "asc"
    @recipes.sort_by! { |recipe| recipe[:name] }
  elsif sort == "desc"
    @recipes.sort_by! { |recipe| recipe[:name] }.reverse!
  end

  content_type :json
  @recipes.to_json
end


get "/stats" do 
  lengths = @recipes.map { |recipe| recipe[:name].length }

  stats = {
    count: lengths.length,
    min: lengths.min,
    max: lengths.max,
    avg: ((lengths.sum.to_f / lengths.length) rescue nil)
  }

  content_type :json
  stats.to_json
end

delete "/recipes/:name" do
  delete_index = @recipes.find_index { |recipe| recipe[:name] == params[:name] }

  if delete_index.nil?
    
    status 404
    return "Recette introuvable"
  end

  @recipes.delete_at(delete_index)
  save_recipes

  status 204
  "Recette supprimée"
end



    run! if app_file == $0
end