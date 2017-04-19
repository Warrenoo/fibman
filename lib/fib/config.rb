module Fib
  class Config
    attr_accessor :controllers, :redis, :targeters

    def configure
      yield(self)
    end
  end
end
