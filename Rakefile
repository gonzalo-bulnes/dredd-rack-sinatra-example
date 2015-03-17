require_relative 'app'

require 'dredd/rack'

Dredd::Rack.app = Dredd::Rack::Sinatra::Example
Dredd::Rack::RakeTask.new # run with `rake dredd`

# Example of custom name and description
namespace :blueprint do
  desc 'Verify an API complies with its blueprint'
  dredd = Dredd::Rack::RakeTask.new(:verify)
  runner =   Dredd::Rack::Runner.new ENV['API_HOST'] do |options|
    options.hookfiles 'doc/hooks/hooks-worker-client.coffee'
  end
  dredd.instance_variable_set :@runner, runner
end
# run with `rake blueprint:verify`
# see also `rake -T`

task default: :dredd
