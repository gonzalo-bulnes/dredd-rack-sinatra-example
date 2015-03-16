require_relative 'app'

require 'dredd/rack'

Dredd::Rack.app = Dredd::Rack::Sinatra::Example
Dredd::Rack::RakeTask.new # run with `rake dredd`

# Example of custom name and description
namespace :blueprint do
  desc 'Verify an API complies with its blueprint'
  Dredd::Rack::RakeTask.new(:verify)
end
# run with `rake blueprint:verify`
# see also `rake -T`

task default: :dredd
