require 'rubygems'
require 'bundler/setup'

module IdeeliStatsd
  class Stat
    @@statsd = nil

    class << self
      def method_missing(meth, *args)
        namespaces.each do |ns|
          statsd.namespace = ns
          statsd.__send__(meth, *args)
        end
      rescue
        # ignore errors
      end

      def statsd
        @@statsd ||= Statsd.new(host, port)
      end

      private

      def host
        'localhost' # TODO app config?
      end

      def port
        8125 # TODO app config?
      end

      def namespaces
        [nil] # TODO
      end
    end
  end
end
