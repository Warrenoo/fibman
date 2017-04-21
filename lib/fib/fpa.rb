# Fib Persistence Adapter
module Fib
  class Fpa
    attr_accessor :redis

    def initialize redis=nil
      @redis = redis
    end

    def save redis_key, content
      redis.sadd redis_key, *content
    end

    def get redis_key
      return nil unless redis.exists(redis_key)
      redis.smembers(redis_key).map(&:to_sym)
    end

    def clear redis_key
      redis.del redis_key
    end
  end
end
