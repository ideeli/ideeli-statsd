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

        # define a delegator method for each valid statsd calls.
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

          # some defaults
          self.yaml_file  ||= '/etc/statsd_config.yaml'
          self.namespaces ||= []

          # further configured via the yaml file
          if yaml = YAML::load(File.open(self.yaml_file)) rescue nil
            self.host ||= yaml['host']
            self.port ||= yaml['port']

            add_default_namespaces(yaml)
          end

        end

        def statsd
          @statsd ||= ::Statsd.new(Resolv.getaddress(host || '127.0.0.1'), port || 8125)
        end

        private

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

        def add_default_namespaces(yaml)
          node_type   = yaml['node_type']
          fqdn        = yaml['fqdn']
          application = yaml['application']

          self.namespaces << [node_type, 'host', fqdn, application].compact.join('.')
          self.namespaces << [node_type, 'app',  application].compact.join('.')
        end

      end
    end
  end
end
