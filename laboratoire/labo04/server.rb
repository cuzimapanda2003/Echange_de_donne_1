require "bundler/inline"
require_relative 'auth'
require "securerandom"
require "json"
require "time"

gemfile do
  source "http://rubygems.org"
  gem "sinatra-contrib"
  gem "rackup"
  gem "puma"
end

require "sinatra/base"
require "sinatra/reloader"
require "openssl"

LINKS_FILE = File.join(__dir__, "user.json")
File.write(LINKS_FILE, "[]") unless File.exist?(LINKS_FILE)

class CustomAuth < Sinatra::Base
  set :bind, "0.0.0.0"
  set :port, 1234
  set :static, false

  configure :development do
    register Sinatra::Reloader
  end

  before do
    authorize
  end

  def authorize
    auth = Rack::Auth::Basic::Request.new(request.env)
    return unless auth.provided? && auth.basic? && auth.credentials
    username, password = auth.credentials
    @user = authenticate(username, password)
  end

  def guard!
    halt 401, { "WWW-Authenticate" => "Basic" }, "Provide a username and password through Basic HTTP authentication" unless @user
  end

  # --- Routes ---
  
  get "/" do
    send_file File.join(__dir__, "gallery.html")
  end

  post "/files" do
    guard!
    file = params["demo_file"] or halt 400, "Missing file"
    
    file_uuid = SecureRandom.uuid
    upload_dir = File.join(__dir__, "uploads")
    Dir.mkdir(upload_dir) unless Dir.exist?(upload_dir)
    save_path = File.join(upload_dir, file[:filename])

    File.open(save_path, "wb") { |f| f.write(file[:tempfile].read) }

    metadata_path = File.join(upload_dir, "_files_metadata.json")
    existing_metadata = File.exist?(metadata_path) ? JSON.parse(File.read(metadata_path)) : {}

    existing_metadata[file_uuid] = {
      "original_name" => file[:filename],
      "uploaded_at"   => Time.now.iso8601,
      "filename"      => file[:filename],
      "owner"         => @user[:username],
      "private"       => !params["password"].to_s.strip.empty?,
      "password"      => params["password"].to_s.strip.empty? ? nil : params["password"]
    }

    File.write(metadata_path, JSON.pretty_generate(existing_metadata))

    headers["Content-Location"] = "/files/#{file_uuid}"
    status 201

    # Ici on simule une transformation: renvoyer le fichier original
    File.read(save_path)
  end

  get "/files" do
    content_type :json
    upload_dir = File.join(__dir__, "uploads")
    Dir.mkdir(upload_dir) unless Dir.exist?(upload_dir)

    metadata_path = File.join(upload_dir, "_files_metadata.json")
    files_metadata = File.exist?(metadata_path) ? JSON.parse(File.read(metadata_path)) : {}

    image_files = Dir.children(upload_dir).select { |f| f =~ /\.(jpg|jpeg|png|gif|txt)$/i && f != "_files_metadata.json" }

    list = image_files.map do |filename|
      file_entry = files_metadata.find { |uuid, data| data["filename"] == filename }
      if file_entry
        uuid, metadata = file_entry
      else
        uuid = filename
        metadata = { "original_name" => filename, "uploaded_at" => Time.now.iso8601.to_s }
      end
      {
        uuid: uuid,
        name: metadata["original_name"] || filename,
        timestamp: metadata["uploaded_at"] || File.mtime(File.join(upload_dir, filename)).to_s,
        private: !!metadata["password"],
        mine: @user && metadata["owner"] == @user[:username]
      }
    end

    # Trier: fichiers de l'utilisateur en premier, puis date desc, puis nom asc
    list.sort_by! do |f|
      [@user && f[:mine] ? 0 : 1, -Time.parse(f[:timestamp]).to_i, f[:name].downcase]
    end

    list.to_json
  end

  get "/files/:uuid" do
    uuid = params[:uuid]
    pass = params[:pass]

    metadata_path = File.join(__dir__, "uploads", "_files_metadata.json")
    files_metadata = JSON.parse(File.read(metadata_path))
    item = files_metadata[uuid] or halt 404, "File not found"

    owner = item["owner"]
    file_pass = item["password"]

    if file_pass && file_pass != pass && (@user.nil? || @user[:username] != owner)
      halt 403, "Access denied"
    end

    {
      uuid: uuid,
      name: item["original_name"],
      timestamp: item["uploaded_at"],
      private: !!file_pass,
      mine: @user && @user[:username] == owner
    }.to_json
  end

  delete "/files/:uuid" do
    guard!
    uuid = params[:uuid]
    upload_dir = File.join(__dir__, "uploads")
    metadata_path = File.join(upload_dir, "_files_metadata.json")
    halt 404, "No metadata file found" unless File.exist?(metadata_path)

    files_metadata = JSON.parse(File.read(metadata_path))
    item = files_metadata[uuid] or halt 404, "File not found"
    halt 403, "Not owner" unless item["owner"] == @user[:username]

    filepath = File.join(upload_dir, item["filename"])
    File.delete(filepath) if File.exist?(filepath)
    files_metadata.delete(uuid)
    File.write(metadata_path, JSON.pretty_generate(files_metadata))

    status 204
  end

  patch "/files/:uuid" do
    guard!
    uuid = params[:uuid]
    new_password = request.body.read.strip

    metadata_path = File.join(__dir__, "uploads", "_files_metadata.json")
    files_metadata = File.exist?(metadata_path) ? JSON.parse(File.read(metadata_path)) : {}

    file = files_metadata[uuid]
    halt 404, "File not found" unless file
    halt 403, "Not owner" unless file["owner"] == @user[:username]

    file["password"] = new_password.empty? ? nil : new_password
    file["private"] = !new_password.empty?
    File.write(metadata_path, JSON.pretty_generate(files_metadata))
    status 204
  end

  get "/login" do
    guard!
    redirect "/", 303
  rescue UnauthorizedError
    headers["WWW-Authenticate"] = "Basic"
    halt 401, "Invalid credentials"
  end

  get "/blazediff/:name1/:name2" do
    name1 = params[:name1]
    name2 = params[:name2]

    upload_dir = File.join(__dir__, "uploads")
    file1 = File.join(upload_dir, name1)
    file2 = File.join(upload_dir, name2)

    halt 404, "Image #{name1} introuvable" unless File.exist?(file1)
    halt 404, "Image #{name2} introuvable" unless File.exist?(file2)

    result = `blazediff diff "#{file1}" "#{file2}" 2>&1`
    content_type "text/plain"
    result
  end

  run! if app_file == $0
end
