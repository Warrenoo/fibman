module Fib
  module RoleInject

    def self.extended(klass)
      Fib.all_roles << klass
      Fib.all_roles.uniq!
    end

    include Fib::ExtPermissions

    attr_accessor :role_name

    def default_permissions
      permissions
    end

    def ext_permissions_custom
      role_name
    end

    def permissions
      @permissions ||= Fib::PermissionsCollection.new
    end

    def use(model, *action)
      action.each do |a|
        permissions.set Fib.all_permissions.get(model.to_s, a.to_s)
      end
    end

  end
end
