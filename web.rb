require 'sinatra'
require 'jwt'


get '/' do
  "Hello, world"
end

get '/jwt' do
  key_file = "key/siwa-demo.p8"
  team_id = "2FYPP5PESL"
  client_id = "com.sampleapp.master.siwa"
  key_id = "UW4AYX6DUH"
  validity_period = 100   # In days. Max 180 (6 months) according to Apple docs.

  private_key = OpenSSL::PKey::EC.new ENV['CERT']

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
  
  "#{token}"
end

get '/.well-known/apple-developer-domain-association.txt' do 
  text = ENV['A_DOMAIN']
  "#{text}"
end