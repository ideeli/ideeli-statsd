require 'rubygems'
require 'bundler/setup'
require 'statsd'

module IdeeliStatsd
  class Stat
    class << self
      # Pass on any method calls to the statsd object. Errors are
      # silently ignored.
      def method_missing(meth, *args)
        namespaces.each do |ns|
          statsd.namespace = ns
          statsd.__send__(meth, *args)
        end
      rescue Exception => e
        logger.debug "statsd error: #{e.message}" if logger
      end

      def namespaces
        @@namespaces ||= [nil]
      end

      def host
        @@host ||= 'localhost'
      end

      def port
        @@port ||= 8215
      end

      def host=(h)
        @@host = h
      end

      def port=(p)
        @@port = p
      end

      def logger
        @@logger ||= nil
      end

      def logger=(l)
        @@logger = l
      end

      private

      def statsd
        @@statsd ||= Statsd.new(host, port)
      end
    end
  end
end
