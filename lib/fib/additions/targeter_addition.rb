module Fib
  module Additions
    module TargeterAddition
      extend ActiveSupport::Concern
      include Fib::Additions::ContainerAddition

      def permissions
        @permissions ||= get_persistence_permissions || Fib::PermissionsCollection.new
      end

      def permissions_info
        permissions.permissions.select{ |p| p.display }.map{ |p| [p.key, p.name] }
      end

      def save_permissions
        fib_container.fpa.save fib_redis_key, permissions.keys
      end

      def build_permissions *permission_keys
        permission_keys = [permission_keys].flatten
        @permissions = fib_container.permissions.extract_by_keys permission_keys
        save_permissions
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
