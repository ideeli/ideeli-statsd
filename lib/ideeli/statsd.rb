require 'singleton'
require 'statsd'
require 'yaml'

module Ideeli
  module Statsd
    # This class is a thin wrapper allowing access to options in the
    #   ideeli statsd config file.
    #
    # It looks for "/etc/statsd_config.yaml" by default.
    #
    # Settings may be accessed using the Options class essentially as a namespace. eg.
    #
    #     Options.foo
    #
    # would return the foo setting
    #
    class Options
      include Singleton
      # allows the user to type Class.foo instead of Class.instance.foo
      def self.method_missing(meth, *args, &block)
        return self.instance.send(meth, *args, &block)
      end

      # Any non-yamled options should be attributes,
      #  since missing methods are pulled from the yaml file
      attr_accessor :logger, :yaml_file, :namespaces

      # Returns the value from the yaml file for the method,
      #   using it as a key
      def method_missing(meth, *args)
        return yaml[meth.to_s] if yaml
      end

      def configure(&block)
        yield self

        # default for the yaml file location
        self.yaml_file  ||= '/etc/statsd_config.yaml'

        # any metrics will be logged in each of the defined namespaces. 
        self.namespaces ||= []
        self.namespaces << [node_type, 'host', fqdn, application].compact.join('.')
        self.namespaces << [node_type, 'app',  application].compact.join('.')
      end

      private

      def yaml
        @yaml ||= YAML::load( File.open(yaml_file) ) rescue nil
      end
    end

    class Client
      private_class_method :new

      def self.method_missing(meth, *args, &block)
        if !Options.namespaces || Options.namespaces.empty?
          statsd.__send__(meth, *args, &block)
        else
          Options.namespaces.each do |ns|
            statsd.namespace = ns
            statsd.__send__(meth, *args, &block)
          end
        end
      rescue Exception => ex
        if logger = Options.logger
          logger.debug "statsd error: #{ex}"
        else
          $stderr.puts "statsd error: #{ex}"
        end
      end

      private

      def self.statsd
        @@statsd ||= ::Statsd.new(Options.host, Options.port)
      end
    end
  end
end
