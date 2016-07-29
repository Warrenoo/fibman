#[Fib](https://github.com/Warrenoo/fib) 是支持动态管理与扩展的独立权限模块
###FEATURE

- 集中权限定义，支持对权限进行组合及分类。
- 支持角色管理，对角色权限进行统一定义。
- 自动完成用户与角色之间的绑定，注入对应权限功能。
- 支持动态扩展用户与角色的权限。

###MODEL

![img](http://7fvkdr.com1.z0.glb.clouddn.com/image2016-7-22%2011-13-10.png)


###USE

1. 进行初始化配置

   ```
   # config/initializers/fib.rb

   Fib.configure do |config|
     config.redis_record = Redis.current   # redis连接对象
     config.user_class = "User"            # 需要管理的用户类
     config.user_role = :role              # 用户角色对应属性
     config.open_ext = true                # 是否开启动态权限
   end

   Fib.loading!                            # 加载工作，必要 
   ```

2. 权限设定与归类

   ```
   # config/initializes/permissions.rb
   
   Fib.build do
     # 增加权限
     # action_name: 权限名称
     # model_name: 模块名称
     # action_package: 对应controller行为集合
     # display: 是否对外显示
     add User, action_name: :show, model_name: "用户",
       action_package: [:show, :index], display: false
       
     # 自定义验证
     # 设定权限时支持添加自定义验证，在默认权限之外对设定的action会额外进行自定义代码块的验证，如果返回true, 验证通过，否则失败。
     # target: 当前验证对象
     # staff: 当前用户
     can_if User, %i(show index) do |target, staff|
       target.user_id == staff.id
     end
     
     # 权限绑定
     
     # 将同一个模块下的不同action_name绑定到第一个设定的action_上
     # 如下是将show的权限绑定到action上面，在拥有action权限的时候将自动拥有show权限
     bind_self User, :action, :show
     
     # 将不同模块下的action_name绑定到一起
     bind User, action, OtherModel, other_action
   end
   
   # 进行完以上设定后，可以通过一系列api对系统权限进行查询
   # 获取全部权限集合
   Fib.all_permissions
   
   # 获取全部可对外显示的权限集合
   Fib.all_permissions.display
   
   # 获取对应权限对象，如果返回nil, 则为不存在改权限对象
   # Fib.all_permissions.get(model, action_name)

   ```
  
3. 权限设定与归类

   ```
   # app/models/permissions/test.rb
   
   # 设定一个角色
   module TestFib
     extend Fib::RoleInject
     
     # 此处与配置设定中的 user_class -> user_role 进行匹配
     self.role_name = "test"
     
     # 设定该角色拥有的权限
     use User, :show
   end
   ```
4. 与cancan进行对接, 对接后可以使用cancan api进行权限验证

   ```
   # app/models/ability.rb
   
   class Bss::Ability
     include CanCan::Ability

     def initialize(staff)
       staff ||= Bss::Staff.new
       instance_exec(&staff.final_permissions.inject_cancan(staff))
     end
   end
   ``` 
5. 获取最终权限及动态扩展自定义权限
  
   ```
   # 最终权限
   staff.final_permissions
   
   new_permissions = params[:permissions].map do |k, v|
     v.blank? ? nil : Fib.all_permissions.get(k, v)
   end.compact

   staff.save_permissions new_permissions # 或者
   role.save_permissions new_permissions

   ```

###DEFECTS

   - 定义新权限时，不支持Rails的热加载，需自行重启server
   - 如果开发模式下对用户类进行了修改，Rails会对用户类进行热加载，这个时候用户权限模块的注入会失效，需要重新进行Fib.reload!, 建议在进行current_user获取的时候进行。
   
     ```
     def current_user
       @current_user ||= User.find_by id: session[:user_id]

       if Rails.env.development? && @current_user && !(@current_user.respond_to? :final_permissions)
         Fib.loading!
         @current_user = nil
         current_user
      end

      @current_user
    end
    ```
    
###TODO
   - 支持动态创建角色的权限注入。
   - 简化api


