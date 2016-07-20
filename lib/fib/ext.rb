module Fib
  module Ext
    class << self
      def data_value(permission, type)
        raise ParameterIsNotValid unless permission.is_a? Fib::Permission
        "#{permission.model}-#{permission.action_name}-#{type}"
      end

      def data_key(custom)
        "fib:ext:#{custom}:permissions"
      end

      def permissions_merge(permissions, custom)
        raise ParameterIsNotValid unless permissions.is_a? Fib::PermissionsCollection

        add_permissions, del_permissions = [], []
        add_permissions, del_permissions = ext_permissions(custom) if Fib::Config.open_ext

        base_permissions =
          if permissions.roles.present?
            permissions.roles.reduce([]) { |l, n| l | n.permissions_group.permissions_array } | permissions.permissions_array
          else
            permissions.permissions_array
          end

        (base_permissions | add_permissions) - del_permissions
      end

      def ext_permissions(custom)
        add_permissions, del_permissions= [], []

        Fib::Config.redis.smembers(redis_key(custom)).each do |data|
          model, action_name, type = data.split("-")
          p = ALL_PERMISSIONS.get(model, action_name)
          next unless p
          add_permissions << p.first if type = "1"
          del_permissions << p.first if type = "0"
        end

        [add_permissions, del_permissions]
      end
    end
  end
end
