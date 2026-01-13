require "openssl"
require "json"

SHA_KEY = "DFkkjhjkfghdrtuJhjfgkhj7676tYEtyut67587buig67O0jObuy7i6"

USERS = JSON.parse(File.read("user.json"), symbolize_names: true)

def sha256(value)
  return nil if value.nil? || value.empty?
  OpenSSL::HMAC.hexdigest("sha256", SHA_KEY, value)
end

def authenticate(username, password)
  hashed = sha256(password)
# alice: pwda, bob: pwdb, charlie: pwdc, dave: pwdd
  USERS
    .find { |user| user[:username] == username && user[:password] == hashed }
    &.slice(:id, :username)
end
