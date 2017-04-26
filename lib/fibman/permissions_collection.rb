module Fibman
  class PermissionsCollection
    extend Forwardable

    attr_reader :permissions, :package
    attr_accessor :container

    # 通过package 快速查询权限
    def_delegators :package, :find_key, :find_url, :find_action

    def initialize
      @permissions = {}
      @package = Fibman::ElementPackage.new
    end

    def permissions_info
      permissions.values.select { |v| v.display }
        .map { |v| [v.key, v.name] }
    end

    def keys
      permissions.keys
    end

    def has? key
      keys.include? key
    end

    def set permission
      raise ParameterIsNotValid, "set method can't accept expect permission object" unless permission.is_a?(Fibman::Permission)
      raise ParameterIsNotValid, "permission key #{permission.key} is exist" if permissions.has_key? permission.key

      mset permission
    end

    alias_method :<<, :set

    def mset *permissions
      permissions.flatten.each do |p|
        next unless p.is_a?(Fibman::Permission)
        @permissions[p.key] = p
      end
      build_package
    end

    alias_method :append, :mset

    def empty?
      permissions.keys.size == 0
    end

    def permission_packages
      (permissions.values.map(&:package) + permissions.values.map(&:bind_packages)).flatten.uniq
    end

    def build_package
      @package = Fibman::ElementPackage.merge *permission_packages
    end

    def + permission_collection
      raise ParameterIsNotValid, "must be permission_collection" unless permission_collection.is_a?(Fibman::PermissionsCollection)

      current_permission_values = permissions.values
      build_new { append *(current_permission_values | permission_collection.permissions.values).flatten }
    end

    alias_method :|, :+

    def - permission_collection
      raise ParameterIsNotValid, "must be permission_collection" unless permission_collection.is_a?(Fibman::PermissionsCollection)

      current_permission_values = permissions.values
      build_new { append *(current_permission_values - permission_collection.permissions.values).flatten }
    end

    def & permission_collection
      raise ParameterIsNotValid, "must be permission_collection" unless permission_collection.is_a?(Fibman::PermissionsCollection)

      current_permission_values = permissions.values
      build_new { append *(current_permission_values & permission_collection.permissions.values).flatten }
    end

    def extract_by_keys keys
      Fibman::PermissionsCollection.build_by_permissions select_permissions_by_keys(keys)
    end

    def select_permissions_by_keys keys
      permissions.select { |k, v| keys.include? k }.values
    end

    def build_new &block
      self.class.new.tap { |n| n.instance_exec(&block) if block_given? }
    end

    def add key, name="", options={}, &block
      return unless key.present?

      keys = [options[:key] || []].flatten
      urls = [options[:url] || []].flatten
      bind = [options[:bind] || []].flatten
      actions = options[:action] || []
      display = options[:display] if options.key? :display

      # 构建权限对象
      permission = Fibman::Permission.new key, name: name

      # 默认创建一个与permission key相同的element key类型
      permission.append Fibman::Element.create_key key
      permission.append keys.map{ |k| Fibman::Element.create_key k }

      permission.append urls.map{ |u| Fibman::Element.create_url u }
      permission.append actions.map{ |a|
        controller = a.shift
        a.map { |action| Fibman::Element.create_action controller, action }
      }.flatten

      permission.bind_permission bind
      display ? permission.display_on : permission.display_off unless display.nil?

      # 执行自定义闭包
      permission.instance_exec &block if block_given?

      # 设置elements所属permission
      permission.inject_elements_permission
      permission.container = container

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
