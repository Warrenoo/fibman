module Fib
  module Role
    MAGIC_NUM = Fib::MAGIC_NUM.freeze

    class << self

      def permissions
        @permissions ||= Fib::PermissionsCollection.new
        @permissions
      end

      def use(model, action)
        @permissions.set ALL_PERMISSIONS.get(model.to_s, action.to_s)
      end

      def role_name
        @role_name
      end

      def role_name=(role_name)
        @role_name = role_name
      end

      def permissions_group
        Fib::Ext.permissions_merge(permissions, role_name)
      end

    end
  end
end
