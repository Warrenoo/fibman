module Fib
  module RoleInject

    def self.included(klass)
      Fib.all_roles << klass
    end

    class << self

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

      def use(model, action)
        @permissions.set Fib.all_permissions.get(model.to_s, action.to_s)
      end

    end

  end
end
