require 'rubygems'
require 'bundler/setup'
require 'statsd'

module IdeeliStatsd
  class Stat
    private_class_method :new

    class << self
      # Pass on any method calls to the statsd object. Errors are
      # silently ignored.
      def method_missing(meth, *args)
        namespaces.each do |ns|
          statsd.namespace = ns
          statsd.__send__(meth, *args)
        end
      rescue Exception => e
        $stderr.puts "statsd error: #{e.message}"
      end

      def namespaces
        @@namespaces ||= [nil]
      end

      def host
        @@host ||= 'localhost'
      end

      def port
        @@port ||= 8125
      end

      def host=(h)
        @@host = h
      end

      def port=(p)
        @@port = p
      end

      private

      def statsd
        @@statsd ||= Statsd.new(host, port)
      end
    end
  end
end
