module Fib
  class Container
    extend Forwardable

    attr_accessor :name, :key, :permissions, :config, :fpa

    def_delegator :permissions, :permissions_info
    def_delegator :config, :configure, :config_configure

    cattr_accessor(:containers) { [] }

    def initialize key, name
      @key = key
      @name = name
      @permissions = Fib::PermissionsCollection.new
      @config = Fib::Config.new
      @fpa = Fib::Fpa.new

      @permissions.container = self
      self.class.containers << self
    end

    def configure &block
      config_configure &block
      loading!
    end

    def loading!
      load_fpa
    end

    def load_fpa
      fpa.redis = config.redis
    end

    def build &block
      permissions.instance_exec &block
    end

    def restore_permissions redis_key
      return unless keys = fpa.get(redis_key)
      permissions.extract_by_keys keys
    end

    class << self; alias_method :ls, :containers; end
  end
end

