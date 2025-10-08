require "bundler/inline"

gemfile do
  source "http://rubygems.org"
  gem "sinatra-contrib"
  gem "rackup"
  gem "webrick"
end

require "sinatra/base"
require "sinatra/reloader"
require "date"
require "securerandom"
require "json"

unless File.exists?("tasks.json")
  File.write("tasks.json", [].to_json)
end

class MySinatraApp < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  set :bind, "0.0.0.0"
  set :port, "1234"

  def get_messages
    JSON.parse(File.read("tasks.json"), symbolize_names: true) rescue []
  end

  before do
    @messages = get_messages
  end

  get "/" do
    send_file File.join(File.dirname(__FILE__), "taskor.html")
  end

  get "/tasks" do
    content_type :json
    tasks = @messages.dup
    if params[:name] && !params[:name].strip.empty?
      critere = params[:name].downcase
      tasks.select! { |t| t[:name].downcase.include?(critere) }
    end
    if params[:status]
      case params[:status]
      when "pending"
        tasks.select! { |t| t[:completed_at].nil? }
      when "done"
        tasks.select! { |t| !t[:completed_at].nil? }
      else
        status 400
        return "Le paramètre 'status' doit être 'pending' ou 'done'."
      end
    end
    if params[:sort]
      case params[:sort]
      when "asc"
        tasks.sort_by! { |t| t[:name].downcase }
      when "desc"
        tasks.sort_by! { |t| t[:name].downcase }.reverse!
      else
        status 400
        return "Le paramètre 'sort' doit être 'asc' ou 'desc'."
      end
    end
    tasks.map { |t| { id: t[:id], name: t[:name], completed_at: t[:completed_at] } }.to_json
  end

  post "/new-task" do
    raw_body = request.body.read
    if raw_body.nil? || raw_body.strip.empty?
      status 400
      return "Le corps de la requête est vide."
    end
    begin
      new_task = JSON.parse(raw_body, symbolize_names: true)
    rescue JSON::ParserError
      status 400
      return "Le format JSON est invalide."
    end
    if !new_task.key?(:name) || new_task[:name].to_s.strip.empty?
      status 400
      return "Le nom de la tâche ne peut pas être vide."
    end
    new_task[:id] = SecureRandom.uuid
    new_task[:completed_at] = nil
    @messages << new_task
    File.write("tasks.json", @messages.to_json)
    ""
  end

  post "/set-completed" do
    update_info = JSON.parse(request.body.read, symbolize_names: true)
    task = @messages.find { |t| t[:id] == update_info[:id] }
    if task
      task[:completed_at] = update_info[:completed] ? Date.today.to_s : nil
      File.write("tasks.json", @messages.to_json)
    end
    ""
  end

  post "/update-name" do
    raw_body = request.body.read
    if raw_body.nil? || raw_body.strip.empty?
      status 400
      return "Le corps de la requête est vide."
    end
    begin
      update_info = JSON.parse(raw_body, symbolize_names: true)
    rescue JSON::ParserError
      status 400
      return "Le format JSON est invalide."
    end
    if !update_info.key?(:name) || update_info[:name].to_s.strip.empty?
      status 400
      return "Le nom de la tâche ne peut pas être vide."
    end
    task = @messages.find { |t| t[:id] == update_info[:id] }
    if task.nil?
      status 404
      return "Tâche non trouvée."
    end
    task[:name] = update_info[:name]
    File.write("tasks.json", @messages.to_json)
    ""
  end

  post "/remove-task" do
    raw_body = request.body.read
    if raw_body.nil? || raw_body.strip.empty?
      status 400
      return "Le corps de la requête est vide."
    end
    begin
      update_info = JSON.parse(raw_body, symbolize_names: true)
    rescue JSON::ParserError
      status 400
      return "Le format JSON est invalide."
    end
    unless update_info.key?(:id)
      status 400
      return "L'identifiant de la tâche est requis."
    end
    task = @messages.find { |t| t[:id] == update_info[:id] }
    if task.nil?
      status 404
      return "Tâche introuvable."
    end
    @messages.reject! { |t| t[:id] == update_info[:id] }
    File.write("tasks.json", @messages.to_json)
    ""
  end

  run! if app_file == $0
end