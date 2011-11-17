# Ideeli Statsd

Log stats via statsd, duplicated in various namespaces.

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

      # There will be default namespaces derived from the environment 
      # but you can also manipulate this array via the configure block
      conf.namespaces << RAILS_ENV
    end

Log metrics:

    def place_order
      IdeeliStatsd::Client.increment "orders_placed" 

      # ...

    end

    def some_long_query
      IdeeliStatsd::Client.time "my_query" do

        # ...

      end
    end

### Commandline

    $ STATSD_HOST='statsd.ideeli.com' statsd-client increment "deployment"

## Actions

All actions supported by [statsd][] have corresponding methods on the 
`Client` class and arguments for the commandline client.

[statsd]: https://github.com/github/statsd-ruby/blob/master/lib/statsd.rb

## Namespacing

When a metric is logged, it is logged in various namespaces determined 
by the environment; this is in addition to any use-specific namepaces 
added during `configure`.

## Configuration

The default options are to log metrics to `localhost:8125`, log errors 
to `$stderr` and duplicate metrics in the various environment-specific 
namespaces as defined by ideeli ops.

All of these can be adjusted through the `configure` method in the case 
of the library and the environment variables `STATSD_HOST` and 
`STATSD_PORT` can be used in the case of the commandline app.
