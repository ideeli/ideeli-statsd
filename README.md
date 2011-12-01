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

~~~ { .ruby }
require 'ideeli/statsd'

Ideeli::Statsd::Client.configure do |conf|
  conf.host   = 'statsd.ideeli.com'
  conf.logger = Rails.logger

  conf.port      = 8125                      # default value
  conf.yaml_file = '/etc/statsd_config.yaml' # default value

  # calling an undefined method means that you're referencing a yaml 
  # key's value. this allows you to add/remove keys in the yaml file and 
  # simply call on those values for additional namespacing here in 
  # environment.rb.
  node_type   = conf.node_type
  fqdn        = conf.fqdn
  application = conf.application

  # any metrics will be logged in each of the defined namespaces. 
  # namespaces defaults to an empty list which would log the metric 
  # once, un-namespaced.
  conf.namespaces << [node_type, 'host', fqdn, application].compact.join('.')
  conf.namespaces << [node_type, 'app', application].compact.join('.')
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
