module Fibman
  class Config
    attr_accessor :redis

    def configure
      yield(self)
    end
  end
end
