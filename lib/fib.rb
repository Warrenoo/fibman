require "forwardable"
require "fib/config"
require "fib/error"
require "fib/ext_permissions"
require "fib/permissions_collection"
require "fib/permission"
require "fib/role_inject"
require "fib/user_inject"
require "fib/action"
require "fib/version"

module Fib
  class << self
    extend Forwardable
    def_delegators Fib::Config, :configure
    def_delegators Fib::PermissionsCollection, :build
    def_delegators Fib::Action, :can_if

    def redis
      Fib::Config.redis_record
    end

    def all_permissions
      Fib::PermissionsCollection.all_permissions
    end

    def all_roles
      @all_roles ||= []
    end

    def loading!
      raise UserClassIsNotFind unless Fib::Config.user_class.present?
      Object.const_get(Fib::Config.user_class).instance_exec { include Fib::UserInject }
    end
  end
end
