module Fib
  module ExtPermissions

    # ext_permissions_custom: 额外权限的redis存储关键字(唯一)
    # default_permissions: 由于会存在关联关系，所以需要设置默认权限对应的权限组对象
    attr_accessor :ext_permissions_custom, :default_permissions

    def default_permissions
      Fib::PermissionsCollection.new
    end

    def ext_permissions_custom
      ""
    end

    def final_permissions
      @final_permissions ||= Fib::Config.open_ext ? ((default_permissions | ext_permissions[1]) - ext_permissions[0]) : default_permissions
    end

    def ext_permissions
      add_permissions, del_permissions= Fib::PermissionsCollection.new, Fib::PermissionsCollection.new

      Fib.redis.smembers(data_key).each do |data|
        model, action_name, type = data.split("-")
        p = Fib.all_permissions.get(model, action_name)
        next unless p
        add_permissions.set p if type == "1"
        del_permissions.set p if type == "0"
      end

      { 1 => add_permissions, 0 => del_permissions }
    end

    def save_ext_permissions(new_permissions)
      raise ParameterIsNotValid unless permissions.is_a? Fib::PermissionsCollection

      add_permissions = new_permissions - default_permissions
      del_permissions = default_permissions - new_permissions

      add_datas = add_permissions.permissions.map { |p| data_value(p, "1") }
      del_datas = del_permissions.permissions.map { |p| data_value(p, "0") }

      Fib.redis.delete(data_key)
      Fib.redis.sadd(data_key, add_datas + del_datas)

      reload_permissions!
    end

    def reload_permissions!
      @final_permissions = nil
    end

    private

    def data_value(permission, type)
      raise ParameterIsNotValid unless permission.is_a? Fib::Permission
      "#{permission.model}-#{permission.action_name}-#{type}"
    end

    def data_key
      "fib:ext_permissions:#{ext_permissions_custom}"
    end
  end
end
