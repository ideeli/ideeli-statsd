require 'statsd'

module Ideeli
  module Statsd
    class Options
      attr_accessor :host, :port, :logger

      def namespaces
        @namespaces ||= []
      end

      private_class_method :new

      def self.defaults
        options = new
        options.host = 'localhost'
        options.port = 8125

        options
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
