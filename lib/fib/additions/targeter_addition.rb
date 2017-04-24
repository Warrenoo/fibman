module Fib
  module Additions
    module TargeterAddition
      extend ActiveSupport::Concern
      include Fib::Additions::ContainerAddition

      delegate :permissions_info, to: :permissions

      # 最终权限来源自于权限范围与持久化权限的并集
      def permissions
        @permissions ||= permissions_scope & (get_persistence_permissions || Fib::PermissionsCollection.new)
      end

      def permissions_scope
        fib_inherit.permissions
      end

      def save_permissions
        fib_container.fpa.save fib_redis_key, permissions.keys
      end

      def create_permissions *permission_keys
        clear_permissions
        new_permissions permission_keys
        save_permissions
      end

      def new_permissions *permission_keys
        permission_keys = [permission_keys].flatten
        @permissions = fib_container.permissions.extract_by_keys permission_keys
      end

      def clear_permissions
        fib_container.fpa.clear fib_redis_key
        @permissions = nil
      end

      def get_persistence_permissions
        fib_container.restore_permissions(fib_redis_key)
      end

      def fib_redis_key
        "Fib:#{fib_container.key}:#{self.class.name}:#{fib_identify}"
      end

      def fib_identify
        raise UnSetTargeterIdentify, "Please rewrite [fib_identify] method and set only sign in #{self.class.name}" unless respond_to? :id
        id
      end
    end
  end
end
