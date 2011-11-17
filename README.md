# Ideeli Statsd

Log stats via statsd duplicated in various namespaces.

## Installation

    git clone https://github.com/...
    bundle install
    rake install

### Rails

Add to `config/environment.rb`:

    require 'ideeli-statsd'

    # optionally
    IdeeliStatsd::Client.configure do |conf|
      conf.host = 'statsd.ideeli.com'
      conf.port = 8125
      conf.namespaces << RAILS_ENV
    end

Log metrics:

    def index
      IdeeliStatsd::Client.increment "index_viewed" 

      # ...
    end

### Commandline

    statsd-client increment "deployment"

## Actions

All actions supported by [statsd][] have corresponding methods on the 
`Client` class and arguments for the commandline client.

[statsd]: https://github.com/github/statsd-ruby/blob/master/lib/statsd.rb

## Namespacing

When a metric is logged, it is logged in various namespaces determined 
by the environment; this is in addition to any namepaces added during 
`configure`.
