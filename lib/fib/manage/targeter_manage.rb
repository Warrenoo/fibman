module Fib
  module Manage
    module TargeterManage
      extend ActiveSupport::Concern

      included do
        attr_accessor :permissions, :fib_identify

        class << self; attr_accessor :fib_container; end
      end

      def permissions
        @permissions ||= get_persistence_permissions || Fib::PermissionCollection.new
      end

      def permissions_info
        permissions.permissions.map{ |p| [p.key, p.name] }
      end

      def save_permissions
        fib_container.fpa.save fib_redis_key, permissions.keys
      end

      def clear_permissions
        fib_container.fpa.clear fib_redis_key
      end

      def get_persistence_permissions
        fib_container.restore_permissions(fib_redis_key)
      end

      def fib_redis_key
        "Fib:#{self.class.name}:#{fib_identify}"
      end

      def fib_identify
        raise UnSetTargeterIdentify, "Please rewrite [fib_identify] method and set only sign in #{self.class.name}" unless respond_to? :id
        id
      end

      def fib_container
        self.class.fib_container
      end
    end
  end
end
