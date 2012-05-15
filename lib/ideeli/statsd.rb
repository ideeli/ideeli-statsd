require 'resolv'
require 'statsd'
require 'yaml'

module Ideeli
  module Statsd
    class Client
      STATSD_METHODS = [ :increment,
                         :decrement,
                         :count,
                         :timing,
                         :time,
                         :gauge ]

      class << self

        # Define a delegator method for each valid statsd calls.
        STATSD_METHODS.each do |method|
          class_eval %[
            def #{method}(*args, &block)
              delegate_to_statsd(#{method.inspect}, *args, &block)
            end
          ]
        end

        attr_accessor :logger, :yaml_file, :host, :port, :namespaces

        def configure
          yield self if block_given?

          self.yaml_file ||= '/etc/statsd_config.yaml'

          if yaml = YAML::load(File.open(self.yaml_file)) rescue nil
            self.host ||= yaml['host']
            self.port ||= yaml['port']

            # yaml attributes used to create the namespaces
            node_type   = yaml['node_type']
            fqdn        = yaml['fqdn']
            application = yaml['application']
          else
            node_type = fqdn = application = nil
          end

          # add the default namespaces
          self.namespaces ||= []
          self.namespaces << [node_type, 'host', fqdn, application].compact.join('.')
          self.namespaces << [node_type, 'app',  application].compact.join('.')
        end

        def statsd
          @statsd ||= ::Statsd.new(Resolv.getaddress(host || '127.0.0.1'), port || 8125)
        end

        def delegate_to_statsd(method, *args, &block)
          if namespaces && namespaces.any?
            namespaces.each do |ns|
              statsd.namespace = ns
              statsd.__send__(method, *args, &block)
            end
          else
            statsd.__send__(method, *args, &block)
          end

        rescue Exception => ex
          if logger = self.logger
            logger.error "statsd error: #{ex}"
          else
            $stderr.puts "statsd error: #{ex}"
          end
        end

      end
    end
  end
end
