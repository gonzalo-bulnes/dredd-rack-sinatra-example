require_relative 'app'

require 'dredd/rack'

Dredd::Rack.app = Dredd::Rack::Sinatra::Example
Dredd::Rack::RakeTask.new # run with `rake dredd`

namespace :dredd do
  namespace :hooks do
    desc 'Try support for Dredd hooks written in Ruby (proof of concept)'
    Dredd::Rack::RakeTask.new(:try) do |task|
      task.runner.configure do |options|
        options.hookfiles 'doc/hooks/hooks-worker-client.coffee'
      end
    end
  end
end

namespace :blueprint do
  desc 'Alias for dredd:hooks:try'
  task :verify => 'dredd:hooks:try'
end

# run with `rake blueprint:verify`
# see also `rake -T`

task default: :dredd
