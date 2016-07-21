module Fib
  class Config
    class << self
      attr_accessor :open_ext, :redis_record, :user_class, :user_role

      def open_ext
        @open_ext ||= false
      end

      def configure
        yield(self)
      end
    end
  end
end
