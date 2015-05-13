Dredd::Rack Sinatra Example
===========================

Demonstrate the [Dredd::Rack][dredd-rack] usage in a Sinatra app.

  [dredd-rack]: https://github.com/gonzalo-bulnes/dredd-rack

Usage
-----

### Run the app

```bash
# run the app
rackup --port=4567
```

### Verify that the application complies with its API blueprint


```bash
# validate the API against its blueprint
rake dredd
```

Please do notice that there is no need to run the application to verify its blueprint.

### How-to add Dredd::Rack to a Sinatra application

1. Store the API blueprints in the `doc` directory, with the `.apib` or `.apib.md` extension
1. Install Dredd::Rack (see the [Dredd::Rack documentation][dredd-rack])
1. Add the `dredd` task to your `Rakefile`

Example:

```ruby
# Gemfile

gem 'dredd-rack', '0.5.0'
```

```ruby
# Rakefile

# ...

require 'dredd/rack'

Dredd::Rack.app = Dredd::Rack::Sinatra::Example # put here the name of your app
Dredd::Rack::RakeTask.new # run with `rake dredd`

# Optinally, add :dredd to the default task
task default: :dredd # run with `rake`
```

That's all!

Documentation
-------------

See the [Dredd::Rack Sinatra Example API blueprint][doc] (`doc/app.apib.md`) for an always up-to-date documentation of this example API. Note how the `.apib.md` extension allows to read the documentation on Github : )

  [doc]: doc/app.apib.md
