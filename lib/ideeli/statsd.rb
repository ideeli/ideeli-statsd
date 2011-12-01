require 'statsd'

module Ideeli
  module Statsd
    class Options
      attr_accessor :host, :port, :logger, :yaml_file

      def namespaces
        @namespaces ||= []
      end

      def method_missing(meth, *args)
        key = meth.to_s

        if yaml && yaml.has_key?(key)
          return yaml[key]
        end

        nil
      end

      private_class_method :new

      def self.defaults
        options = new
        options.host = 'localhost'
        options.port = 8125
        options.yaml_file = '/etc/statsd_config.yaml'

        options
      end

      private

      def yaml
        unless @yaml
          require 'yaml'
          @yaml = YAML::load( File.open(yaml_file) ) rescue nil
        end

        @yaml
      end
    end

    class Client
      private_class_method :new

      @@options = Options.defaults

      class << self
        def method_missing(meth, *args)
          namespaces = @@options.namespaces

          if namespaces.empty?
            statsd.__send__(meth, *args)
          else
            @@options.namespaces.each do |ns|
              statsd.namespace = ns
              statsd.__send__(meth, *args)
            end
          end
        rescue Exception => ex
          if logger = @@options.logger
            logger.debug "statsd error: #{ex}"
          else
            $stderr.puts "statsd error: #{ex}"
          end
        end

        def configure(&block)
          yield @@options
        end

        private

        def statsd
          @@statsd ||= ::Statsd.new(@@options.host, @@options.port)
        end
      end
    end
  end
end
