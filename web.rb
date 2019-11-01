require 'sinatra'
require 'jwt'
require 'net/http'
require 'json'

set :public_folder, File.dirname(__FILE__) + '/public'

get '/' do
  "Hello, world"
end

get '/jwt' do
  token = jwt("com.test.app")
  "#{token}"
end


get '/link' do
  code = params[:code]
  client_id = params[:client_id]
  jwt = jwt(client_id)

  params = {
           :code => code,
           :grant_type   => "authorization_code",
           :client_id   => client_id,
           :client_secret => jwt
  }
  uri = URI('https://appleid.apple.com/auth/token')
#  uri.query = URI.encode_www_form(params)

  res = Net::HTTP.post_form(uri, params)

  {
    :code => code,
    :client_id => client_id,
    :response => {
      :code => res.code,
      :body => res.body,
      :message => res.message
    }
  }.to_json
end

def jwt (client_id)  
  key_file = "key/siwa-demo.p8"
  team_id = "2FYPP5PESL"
  key_id = "UW4AYX6DUH"
  validity_period = 100   # In days. Max 180 (6 months) according to Apple docs.

  private_key = OpenSSL::PKey::EC.new ENV['CERT']

  if !private_key.to_s.empty?
    private_key = OpenSSL::PKey::EC.new IO.read key_file
  end

  token = JWT.encode(
    {
      iss: team_id,
      iat: Time.now.to_i,
      exp: Time.now.to_i + 86400 * validity_period,
      aud: "https://appleid.apple.com",
      sub: client_id
    },
    private_key,
    "ES256",
    {
      kid: key_id
    }
  )
end
