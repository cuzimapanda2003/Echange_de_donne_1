# client.rb
require "io/console"
require "net/http"
require "json"
require_relative "auth"

SERVER = "http://localhost:1234"

def clear
  system("clear") || system("cls")
end

def wait_enter(msg = "Press a key to continue...")
  print("\n#{msg}")
  STDIN.noecho(&:getch)
end

def header
  puts("~~~~~~   LINKY   ~~~~~~")
end

# === LOGIN ===
def login
  clear
  print("Username: ")
  username = gets.strip

  print("Password: ")
  password = gets.strip

  user = authenticate(username, password)

  if user.nil?
    clear
    header
    puts("Invalid credentials\n")
    wait_enter("Press a key to quit...")
    exit
  else
    @current_user = { username: username, password: password }
  end
end

# === HTTP HELPERS ===
def http_request(method, path, body = nil)
  uri = URI("#{SERVER}#{path}")
  klass = {
    get: Net::HTTP::Get,
    post: Net::HTTP::Post,
    patch: Net::HTTP::Patch,
    delete: Net::HTTP::Delete
  }[method]

  req = klass.new(uri)
  req.basic_auth(@current_user[:username], @current_user[:password])
  req["Content-Type"] = "application/json" if body
  req.body = body.to_json if body

  Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }
end

# === LIST ===
def list
  clear
  header

  res = http_request(:get, "/links")

  if res.code.to_i == 200
    links = JSON.parse(res.body)
    links.each do |link|
      puts("#{SERVER}/l/#{link['hash']}")
      puts(" ↪  #{link['url']}")
    end
  else
    puts("Failed to fetch links")
  end

  wait_enter
end

# === ADD ===
def add
  clear
  header
  print("URL: ")
  url = gets.strip

  res = http_request(:post, "/links", { url: url })

  case res.code.to_i
  when 200
    data = JSON.parse(res.body)
    puts("\nNew link added: #{SERVER}/l/#{data['hash']}")
  when 400
    puts("Invalid URL, host unreachable")
  else
    puts("Error: #{res.body}")
  end

  wait_enter
end

# === EDIT ===
def edit
  clear
  header
  print("Hash: ")
  hash = gets.strip
  print("URL: ")
  url = gets.strip

  res = http_request(:patch, "/links/#{hash}", { url: url })

  case res.code.to_i
  when 200
    data = JSON.parse(res.body)
    puts("\nLink updated")
    puts("#{SERVER}/l/#{data['hash']}")
    puts(" ↪  #{data['url']}")
  when 404
    puts("\nLink not found")
  else
    puts("\nError: #{res.body}")
  end

  wait_enter
end

# === DELETE ===
def delete
  clear
  header
  print("Hash: ")
  hash = gets.strip

  res = http_request(:delete, "/links/#{hash}")

  case res.code.to_i
  when 200
    puts("\nLink deleted")
  when 404
    puts("\nLink not found")
  else
    puts("\nError: #{res.body}")
  end

  wait_enter
end

# === QUIT ===
def quit
  clear
  exit
end

# === MENU ===
def menu_input
  clear
  header
  puts("l: List  a: Add  e: Edit  d: Delete  q: Quit")
  print(">> ")
  gets.strip.downcase
end

def menu
  login

  loop do
    choice = menu_input
    clear
    header

    case choice
    when "l" then list
    when "a" then add
    when "e" then edit
    when "d" then delete
    when "q" then quit
    else
      puts("Invalid choice!")
      wait_enter
    end
  end
end

menu
