# Ideeli Statsd

This gem centralizes additional logic around metrics logging via statsd. 
Emphasis is on namespace management for metrics coming from (rails) 
applications and periodic "events" like deployments and outages (logged 
via a commandline client).

## Installation

    git clone https://github.com/ideeli/ideeli-statsd
    cd ideeli-statsd
    bundle install
    rake install
    cp statsd_config.yaml /etc/statsd_config.yaml

Note that you can place the statsd_config.yaml file elsewhere if you choose and point to it. See the next section.

### Rails

Add to `config/initializers/statsd.rb`:

~~~ { .ruby }
require 'ideeli'
require 'ideeli/statsd'

Ideeli::Statsd::Options.configure do |option|
  option.logger    = Rails.logger
  option.yaml_file = '/etc/statsd_config.yaml'
end
~~~

Log metrics:

~~~ { .ruby }
def place_order
  Ideeli::Statsd::Client.increment "orders.placed"

  # ...

end

def some_long_query
  Ideeli::Statsd::Client.time "my_query" do

    # ...

  end
end
~~~

### Commandline

    $ STATSD_HOST='statsd.ideeli.com' statsd-client increment deployment

If a yaml file other than `/etc/statsd_config.yaml`should be used, set 
`STATSD_CONFIG` as well. The commandline app will namespace metrics as 
`<node_type>.app.<application>` pulling the varying components from the 
defined yaml file.

## Actions

All actions supported by [statsd][] have corresponding methods on the 
`Client` class and arguments for the commandline client.

[statsd]: https://github.com/github/statsd-ruby/blob/master/lib/statsd.rb
