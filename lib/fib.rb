require "forwardable"
require "fib/config"
require "fib/trie"
require "fib/element"
require "fib/element_package"
require "fib/error"
require "fib/ext_permissions"
require "fib/permissions_collection"
require "fib/permission"
require "fib/role_inject"
require "fib/user_inject"
require "fib/action"
require "fib/handle_sub"
require "fib/version"

module Fib
  class << self
    extend Forwardable
    def_delegators Fib::Config, :configure, :open_ext
    def_delegators Fib::PermissionsCollection, :build
    def_delegators Fib::Action, :can_if
    def_delegators Fib::HandleSub, :handle

    def redis
      Fib::Config.redis_record
    end

    def all_permissions
      Fib::PermissionsCollection.all_permissions
    end

    def all_roles
      @all_roles ||= []
    end

    def get_role_by_name(role_name)
      all_roles.find { |r| r.role_name == role_name }
    end

    def listen_cache!
      mutex.synchronize do
        return nil if subscribed
        Thread.new do
          Fib.redis.dup.subscribe("permission_events") do |event|
            event.message { |channel, body| Fib.handle body }
          end
        end
        self.subscribed = true
      end
    end

    def loading!
      raise UserClassIsNotFind unless Fib::Config.user_class.present?
      Object.const_get(Fib::Config.user_class).instance_exec { include Fib::UserInject }
    end

    private

    attr_writer :subscribed

    def mutex
      @mutex ||= Mutex.new
    end

    def subscribed
      @subscribed ||= false
    end
  end
end
