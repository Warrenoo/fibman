module Fib
  module UserInject

    include Fib::ExtPermissions

    def fib_role_class
      raise Fib::RoleIsNotFind unless respond_to? Fib::Config.user_role
      @fib_role_class ||= Fib.all_roles.find { |r| r.role_name.to_s == send(Fib::Config.user_role) }
    end

    def default_permissions
      fib_role_class.final_permissions
    end

    def ext_permissions_custom
      respond_to?(:id) ? "user-#{id}" : ""
    end

    def permissions
      @permissions ||= Fib::PermissionsCollection.new
    end

  end
end
