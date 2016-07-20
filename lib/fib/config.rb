module Fib
  class Config
    class << self
      def open_ext
        @open_ext ||= false
        @open_ext
      end

      def open_ext=(bool)
        @open_ext = bool
      end

      def redis_record
        @redis_record
      end

      def redis_record=(redis)
        @redis_record = redis
      end

      def setting
        yield(self)
      end
    end
  end
end
