module Fib
  class PermissionsCollection
    attr_accessor :roles, :permissions, :permissions_array

    def initialize
      @roles = []
      @permissions = {} # for search
      @permissions_array = [] # for merge
    end

    # find permission from collection
    def get(model, action)
      return nil unless @permissions.has_key? model
      return nil unless @permissions[model].has_key? action
      @permissions[model][action]
    end

    def set(permission)
      raise ParameterIsNotValid, "set method can't accept expect permission object" unless permission.is_a?(Fib::Permission)
      @permissions[permission.model] ||= {}
      @permissions[permission.model][permission.action_name] = permission
      @permissions_array | [permission]
    end

    def delete(permission)
      raise ParameterIsNotValid, "set method can't accept expect permission object" unless permission.is_a?(Fib::Permission)
      @permissions[permission.model] ||= {}
      @permissions[permission.model].delete[permission.action_name]
      @permissions_array.delete permission
    end

    # add new permission
    def add_permission(*options)
      if options.size < 2 && options.first.is_a?(Fib::Permission)
        set options.first
      else
        set Fib::Permission.new(*options)
      end
    end

    def add_role(role)
      raise ParameterIsNotValid, "add_role method can't accept expect role object" unless role.const_defined?("MAGIC_NUM") && role.const_get("MAGIC_NUM") == Fib::MAGIC_NUM
      @roles | [role]
    end

    def permissions_group(custom="")
      Fib::Ext.permissions_merge(permissions, custom)
    end

    class << self
      def all_permissions
        @all_permissions
      end

      def build(&block)
        @all_permissions = new
        @all_permissions.instance_exec(&block)
      end

      def build_by_permissions(permissions)
        return unless permissions.present?
        pc = Fib::PermissionsCollection.new
        permissions.each { |p| pc.set p }
        pc
      end
    end
  end
end
