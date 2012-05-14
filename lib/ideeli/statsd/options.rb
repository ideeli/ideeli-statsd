require 'forwardable'
require 'singleton'
require 'yaml'

module Ideeli
  module Statsd
    # This class is a thin wrapper allowing access to options in the
    # ideeli statsd config file.
    class Options
      include Singleton

      class << self
        extend Forwardable

        # we delegate these methods to our singleton instance
        def_delegators :instance, :configure, :logger, :yaml_file,
          :namespaces, :host, :port, :node_type, :fqdn, :application
      end

      # exceptions will be logged with the debug method on this object
      # if present, otherwise they will go to stderr.
      attr_accessor :logger

      # host-specific options are read from this yaml file. the default
      # location is /etc/statsd_config.yaml.
      attr_accessor :yaml_file

      # additional namespaces to increment metrics in. two composite
      # namespaces derived from the yaml settings will exist, you are
      # free to add any additional namespaces here.
      attr_accessor :namespaces

      # these are parsed from the yaml file, they repesent graphite
      # connection info and host qualifications.
      attr_accessor :host, :port, :node_type, :fqdn, :application
      
      def configure(&block)
        yield self if block_given?

        # default for the yaml file location
        self.yaml_file ||= '/etc/statsd_config.yaml'

        # read additional settings therefrom
        init_from_yaml

        # any metrics will be logged in each of the defined namespaces. 
        self.namespaces ||= []
        self.namespaces << [node_type, 'host', fqdn, application].compact.join('.')
        self.namespaces << [node_type, 'app',  application].compact.join('.')
      end

      private

      def init_from_yaml
        @yaml ||= YAML::load( File.open(self.yaml_file) ) rescue nil

        ['host', 'port', 'node_type', 'fqdn', 'application'].each do |key|
          self.send("#{key}=", @yaml[key]) if @yaml && @yaml[key]
        end
      end
    end
  end
end
