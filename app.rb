require 'sinatra/base'

module Dredd
  module Rack
    module Sinatra
      class Example < ::Sinatra::Base

        get '/' do
          status = 200
          headers = {'content-type' => 'application/json; charset=utf-8'}
          body = '{"message": "Hello, world!"}'

          [status, headers, body]
        end
      end
    end
  end
end
