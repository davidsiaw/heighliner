require 'sinatra'

set :host_authorization, { permitted_hosts: [] }

get '/' do
  "Hello from Heighliner test app!"
end

get '/health' do
  'OK'
end

run Sinatra::Application
