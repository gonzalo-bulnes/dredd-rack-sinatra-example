
require 'socket'
require 'json'

HOST = '127.0.0.1'
PORT = 61321
MESSAGE_DELIMITER = "\n"

@before_hooks = {}
@after_hooks = {}

def before transaction_name, &block
  @before_hooks[transaction_name] = [] if @before_hooks[transaction_name].nil?
  @before_hooks[transaction_name].push block
end

def after transaction_name, &block
  @after_hooks[transaction_name] = [] if @after_hooks[transaction_name].nil?
  @after_hooks[transaction_name].push block
end

def run_before_hooks_for_transaction transaction
  transaction_name = transaction["name"]
  hooks = @before_hooks[transaction_name]
  if hooks.kind_of? Array
    hooks.each do |hook_proc|
      hook_proc.call transaction
    end
  end
  return transaction
end

def run_after_hooks_for_transaction transaction
  transaction_name = transaction["name"]
  hooks = @after_hooks[transaction_name]
  if hooks.kind_of? Array
    hooks.each do |hook_proc|
      hook_proc.call transaction
    end
  end
  return transaction
end

def process_message message, client
  event = message['event']
  transaction = message['transaction']
  if event == "before"
    transaction = run_before_hooks_for_transaction transaction
  end

  if event == "after"
    transaction = run_after_hooks_for_transaction transaction
  end

  to_send = {
    "uuid" => message['uuid'],
    "event" => event,
    "transaction" => transaction
  }.to_json
  client.puts to_send + "\n"
end

def run_server
  server = TCPServer.new HOST, PORT
  loop do
    #Thread.abort_on_exception=true
    client = server.accept
    STDERR.puts 'Dredd connected to Ruby Dredd hooks worker'
    buffer = ""
    while (data = client.recv(10))
      buffer += data
      if buffer.include? MESSAGE_DELIMITER
        splitted_buffer = buffer.split(MESSAGE_DELIMITER)
        buffer = ""

        messages = []

        splitted_buffer.each do |message|
          begin
            messages.push JSON.parse(message)

          rescue JSON::ParserError
            # if message aftger delimiter is not parseable json, it's
            # a chunk of next message, put it back to the buffer
            buffer += message
          end
        end

        messages.each do |message|
          process_message message, client
        end
      end
      ensure_the_ruby_process_gets_killed!
    end
    STDERR.puts 'Closing socket...'
    client.close
  end
end

# Does actually ensure that the Ruby process gets killed
#
# I noticed that the Ruby process didn't get killed. As a
# consequence, it was impossible to successfully run the rake task
# twice. ("successfully" means: "Yay! Failed in ruby hook.")
#
# Do notice that the 'Closing socket...' message never gets printed.
#
# Printing 'anything' does in fact ensure the Ruby process gets killed,
# even if it does not provoke the 'Closing socket...' print.
# My understanding of sockets is insufficient to explain this result,
# but that's what I've observed.
#
def ensure_the_ruby_process_gets_killed!
  STDERR.puts 'anything' if buffer.empty?
end

#
# Register hooks here!
#

# If you want to pass output from ruby worker to Dredd report,
# you have to use STDERR.puts. Puts to stdout is swalowed somewhere
#

# Tranasction object in the block is passed back to Dredd, so you can
# modify it, save response to stash, or programatically fail the transaction
# by setting trabsaction['fail'] to some message
#
# Let's inspect transaction object:
#
# STDERR.puts JSON.pretty_generate(transaction)

stash = ""

before ' > Hello, world! > Retrieve Message' do |transaction|
  stash = 'stashed data'
  STDERR.puts 'Before hook in Ruby'
  transaction['fail'] = 'Yay! Failed in ruby hook.'
end


after ' > Hello, world! > Retrieve Message' do |transaction|
   STDERR.puts 'After hook in Ruby'
   STDERR.puts 'Stash content: ' + stash
end


# Run hooks server
STDERR.puts 'Dredd Ruby hooks worker is running'

run_server

