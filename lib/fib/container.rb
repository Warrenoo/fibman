module Fib
  class Container
    extend Forwardable

    attr_accessor :name, :permissions, :config, :fpa

    def_delegators :config, :configure

    def initialize name
      @name = name
      @permissions = Fib::PermissionsCollection.new
      @config = Fib::Config.new
      @fpa = Fib::Fpa.new config.redis
    end

    def configure
      super
      loading!
    end

    def loading!
      inject_targeters
      inject_controllers
    end

    def build
      permissions.instance_exec { yield }
    end

    def restore_permissions redis_key
      permissions.extract_by_keys fpa.get(redis_key)
    end

    private

    def inject_targeters
      config.targeters.each do |t|
        next if t.respond_to? :fib_container

        t.include Fib::Manage::TargeterManage
        c.fib_container = self
      end
    end

    def inject_controllers
      config.controllers.each do |c|
        if defined?(Rails) && c.ancestors.include?(ActionController::Metal)
          next if t.respond_to? :fib_container

          c.include Fib::Manage::RailsControllerManage
          c.fib_container = self
        end
      end
    end

  end
end
