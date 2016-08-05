module Fib
  class Config
    class << self
      attr_accessor :open_ext, :redis_record, :user_class, :user_role

      def open_ext
        @open_ext ||= false
      end

      def configure_without_subscribe
        @mutex, @subscribed = Mutex.new, false

        yield(self)
      end

      def configure(&block)
        configure_without_subscribe(&block)
        @mutex.synchronize do        
          return nil if @subscribed
          Thread.new do
            Fib.redis.subscribe("permission_events") do |event|
              event.message do |channel, body|
                p "permission_events recive: #{body}"
                Fib.all_roles.each{|r| r.reload_permissions! }
              end
            end
          end
          @subscribed = true
        end
      end
    end
  end
end
