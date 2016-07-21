module Fib
  module UserInject

      include Fib::ExtPermissions

      def fib_role_class
        raise Fib::RoleIsNotFind unless respond_to? Fib::Config.user_role
        guess_role_class_name = "#{send(Fib::Config.user_role)}_fib".gsub(/^.|_./){ |m| m.size > 1 ? m[1].upcase : m.upcase }
        @fib_role_class ||= Fib.all_roles.find { |r| r.to_s == guess_role_class_name }
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

      def final_permissions
        Fib::Config.open_ext ? super : permissions
      end

    end
end
