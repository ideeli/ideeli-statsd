# Ideeli Statsd

This gem centralizes additional logic around metrics logging via statsd. 
Emphasis is on namespace management for metrics coming from (rails) 
applications and periodic "events" like deployments and outages (logged 
via a commandline client).

## Installation

    git clone https://github.com/ideeli/ideeli-statsd
    bundle install
    rake install

### Rails

Add to `config/environment.rb`:

    require 'ideeli/statsd'

    Ideeli::Statsd::Client.configure do |conf|
      conf.host = 'statsd.ideeli.com'
      conf.logger = Rails.logger

      # derive a specific and aggregate namespace from the environment 
      # the rails app is running in

      node_type   = 'www'
      fqdn        = Socket.gethostbyname(Socket.gethostname).first rescue nil
      application = "ideeli_#{Rails.env}" rescue nil

      namespaces << [node_type, 'host', fqdn, application].compact.join('.')
      namespaces << [node_type, 'app', application].compact.join('.')
    end

Log metrics:

    def place_order
      Ideeli::Statsd::Client.increment "orders.placed"

      # ...

    end

    def some_long_query
      Ideeli::Statsd::Client.time "my_query" do

        # ...

      end
    end

### Commandline

    $ STATSD_HOST='statsd.ideeli.com' NODE_TYPE='www' RAILS_ENV='production' \
        statsd-client increment deployment

## Actions

All actions supported by [statsd][] have corresponding methods on the 
`Client` class and arguments for the commandline client.

[statsd]: https://github.com/github/statsd-ruby/blob/master/lib/statsd.rb
