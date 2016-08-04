module Fib
  class Config
    class << self
      attr_accessor :open_ext, :redis_record, :user_class, :user_role

      def open_ext
        @open_ext ||= false
      end

      def configure_without_subscribe
        yield(self)
      end

      def configure(&block)
        configure_without_subscribe(&block)
        Thread.new do
          Fib.redis.subscribe("permission_events") do |event|
            event.message do |channel, body|
              p "permission_events recive: #{body}"
              Fib.handle_event(body)
            end
          end
        end
      end
    end
  end
end
