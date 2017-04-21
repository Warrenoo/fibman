module Fib
  class PermissionsCollection
    extend Forwardable

    attr_reader :permissions, :package

    # 通过package 快速查询权限
    def_delegators :package, :find_key, :find_url, :find_action

    def initialize
      @permissions = {}
      @package = Fib::ElementPackage.new
    end

    def permissions_info
      permissions.values.select { |v| v.display }
        .map { |v| [v.key, v.name] }
    end

    def keys
      permissions.keys
    end

    def set permission
      raise ParameterIsNotValid, "set method can't accept expect permission object" unless permission.is_a?(Fib::Permission)
      raise ParameterIsNotValid, "permission key #{permission.key} is exist" if permissions.has_key? permission.key

      @permissions[permission.key] = permission
      @package += permission.package
    end

    alias_method :<<, :set

    def mset *permissions
      permissions.flatten.each do |p|
        next unless p.is_a?(Fib::Permission)
        set p
      end
    end

    alias_method :append, :mset

    def empty?
      permissions.keys.size == 0
    end

    def build_package
      @package = Fib::ElementPackage.merge *permissions.values.map(&:package).flatten.uniq
    end

    def + permission_collection
      raise ParameterIsNotValid, "must be permission_collection" unless permission_collection.is_a?(Fib::PermissionsCollection)
      append *permission_collection.permissions.values
    end

    alias_method :|, :+

    def - permission_collection
      raise ParameterIsNotValid, "must be permission_collection" unless permission_collection.is_a?(Fib::PermissionsCollection)

      permissions.delete_if { |k, v| permission_collection.permissions.keys.include?(k) }
      build_package
      self
    end

    def & permission_collection
      raise ParameterIsNotValid, "must be permission_collection" unless permission_collection.is_a?(Fib::PermissionsCollection)

      permissions.delete_if { |k, v| !permission_collection.permissions.keys.include?(k) }
      build_package
      self
    end

    def extract_by_keys keys
      Fib::PermissionsCollection.build_by_permissions select_permissions_by_keys(keys)
    end

    def select_permissions_by_keys keys
      permissions.select { |k, v| keys.include? k }.values
    end

    def add key, name="", options={}, &block
      return unless key.present?

      keys = [options[:key] || []].flatten
      urls = [options[:url] || []].flatten
      bind = [options[:bind] || []].flatten
      actions = options[:action] || []
      display = options[:display] if options.key? :display

      # 构建权限对象
      permission = Fib::Permission.new key, name: name

      # 默认创建一个与permission key相同的element key类型
      permission.append Fib::Element.create_key key
      permission.append keys.map{ |k| Fib::Element.create_key k }

      permission.append urls.map{ |u| Fib::Element.create_url u }
      permission.append actions.map do |a|
        controller = a.shift
        a.map { |action| Fib::Element.create_action controller, action }
      end.flatten

      permission.bind_permission bind
      display ? permission.display_on : permission.display_off unless display.nil?

      # 执行自定义闭包
      permission.instance_exec &block if block_given?

      # 设置elements所属permission
      permission.inject_elements_permission

      # 将该权限放入集合
      set permission
    end


    class << self
      def build_by_permissions permissions
        return unless permissions.is_a? Array
        new.tap { |p| p.append(*permissions) }
      end
    end
  end
end
