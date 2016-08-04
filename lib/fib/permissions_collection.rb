module Fib
  class PermissionsCollection
    # permissions: array for merge
    # permissions_map: hash for search
    attr_accessor :permissions, :permissions_map

    def initialize
      @permissions = []
      @permissions_map = {}
    end

    # find permission from collection
    def get(model, action)
      return nil unless @permissions_map.key? model
      return nil unless @permissions_map[model].key? action
      @permissions_map[model][action]
    end

    def set(permission)
      raise ParameterIsNotValid, "set method can't accept expect permission object" unless permission.is_a?(Fib::Permission)
      @permissions_map[permission.model] ||= {}
      @permissions_map[permission.model][permission.action_name] = permission
      @permissions |= [permission]
    end

    alias_method :<<, :set

    def mset(*permissions)
      permissions.flatten.each do |p|
        next unless p.is_a?(Fib::Permission)
        set p
      end
    end

    def delete(permission)
      raise ParameterIsNotValid, "set method can't accept expect permission object" unless permission.is_a?(Fib::Permission)
      @permissions_map[permission.model] ||= {}
      @permissions_map[permission.model].delete[permission.action_name]
      @permissions.delete permission
    end

    def add(*options)
      if options.size < 2 && options.first.is_a?(Fib::Permission)
        set options.first
      else
        set Fib::Permission.new(*options)
      end
    end

    def bind(klass_1, action_1, klass_2, action_2)
      raise PermissionIsNotFind unless check_model_action(klass_1, action_1)
      raise PermissionIsNotFind unless check_model_action(klass_2, action_2)

      @permissions_map[klass_1.to_s][action_1.to_s].bind << @permissions_map[klass_2.to_s][action_2.to_s]
    end

    def bind_self(klass, *action_arr)
      first_action = action_arr.shift
      raise PermissionIsNotFind unless check_model_action(klass.to_s, first_action.to_s)

      record = @permissions_map[klass.to_s][first_action.to_s]

      action_arr.each do |a|
        next unless check_model_action(klass, a)
        record.bind << @permissions_map[klass.to_s][a.to_s]
      end
    end

    def empty?
      @permissions.empty?
    end

    %w(+ - & |).each do |a|
      define_method a do |permissions|
        raise ParameterIsNotValid unless permissions.is_a? Fib::PermissionsCollection
        self.class.build_by_permissions(self.permissions.send(a, permissions.permissions))
      end
    end

    def inject_cancan(user)
      params = permission_params(user)

      proc do
        params.each do |p|
          p.key?(:cond) ? can(*p[:default], &p[:cond]) : can(*p[:default])
        end
      end
    end

    def permission_params(user)
      permissions.map do |p|

        default_params =
          p.action_package.map do |a|
            attrs = { default: [a.action_name.to_sym, Object.const_get(a.model)] }
            attrs[:cond] = proc { |target| a.condition[target, user] } if a.condition.present?
            attrs
          end

        bind_params =
          if p.bind.empty?
            []
          else
            p.bind.permission_params(user)
          end

        default_params + bind_params

      end.flatten.uniq
    end

    def check_model_action(model, action)
      hash = @permissions_map[model.to_s]
      return false unless hash.is_a? Hash
      record = hash[action.to_s]
      return false unless record.is_a? Fib::Permission

      true
    end

    def display
      @display ||= self.class.build_by_permissions @permissions.select { |p| p.display }
    end

    extend Forwardable
    require 'fib/action'
    def_delegators Fib::Action, :can_if

    class << self
      def all_permissions
        @all_permissions ||= new
      end

      def build(&block)
        all_permissions.instance_exec(&block)
      end

      def build_by_permissions(permissions)
        return unless permissions.is_a? Array
        new.tap { |p| p.mset permissions }
      end

      def handle_event(message)
        event, *permissions = message.split('|')
        permission_hash = Hash[*permissions]
        send(event, permission_hash) if respond_to?(event)
      end

      def add_permission(permissions)
        all_permissions do
          permissions.each_pair do |model_name, action|
            model = (Module.const_get(model_name) rescue nil)
            add(model, action_name: action) if model
          end
        end
      end

      def del_permission(permissions)
        all_permissions do
          permissions.each_pair do |model_name, action|
            model = (Module.const_get(model_name) rescue nil)
            @permissions_map[model].delete(action) if model && @permissions_map[model]
          end
        end
      end
    end
  end
end
