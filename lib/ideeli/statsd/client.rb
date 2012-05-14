require 'statsd'
require 'forwardable'

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
        # define a delgator for each valid statsd call that sends the
        # call in each namespace as well as catches any errors.
        STATSD_METHODS.each do |method|
          class_eval %[
            def #{method}(*args, &block)
              if !Options.namespaces || Options.namespaces.empty?
                statsd.__send__(#{method.inspect}, *args, &block)
              else
                Options.namespaces.each do |ns|
                  statsd.namespace = ns
                  statsd.__send__(#{method.inspect}, *args, &block)
                end
              end

            rescue Exception => ex
              if logger = Options.logger
                logger.debug "statsd error: \#{ex}"
              else
                $stderr.puts "statsd error: \#{ex}"
              end
            end
          ]
        end

        private

        def statsd
          @statsd ||= ::Statsd.new(Options.host, Options.port)
        end
      end

      # just to protect ourselves
      private_class_method :new
    end
  end
end
