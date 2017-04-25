= Fibman
{<img src="https://fury-badge.herokuapp.com/rb/fibman.png" alt="Gem Version" />}[http://badge.fury.io/rb/fibman]

[Fibman](https://github.com/Warrenoo/fibman) 是提供系统权限管理验证的模块


## 功能

- 支持持久化对象权限
- 定义多种权限维度, 高自由度的权限验证
- 快速定义权限管理对象，注入完善的管理模块
- 支持对象间权限依赖关系的拓展
- 支持权限与权限间的绑定
- 全方位的权限校验支持
- 支持单系统多权限模块的组织结构

## 安装

添加到 Gemfile:

    gem 'fibman', '~> 2.0'

并运行 `bundle install` 命令。

## 开始

### 1. 初始化一个权限模块

Fib.new 作为创建权限管理系统的入口，需要定义一个名称和唯一的key

Fib 初始化后可以进行权限的定义与管理

可以在一个系统中定义多个Fibman对象，分别定义不同的权限类型，并管理不同的模块

```ruby
demo_fib = Fibman.new(:demo, "权限系统示例")
```

### 2. 配置持久化连接

Fibman 使用 Redis 提供数据持久化服务，所以需要配置 redis 的连接对象，默认使用`gem redis-rb`中的api

```
demo_fib.configure { |c| c.redis = Redis.current }
```

### 3. 权限定义

在Fib中，支持三种权限维度的设定

- URL    设定某个URL
- KEY    设定某个自定义Key
- ACTION MVC框架中，设定Controller层具体Action

通过调用`build`方法构建当前权限系统的权限集

使用`add`方法来定义权限集

每个权限集可以包含若干具体的权限维度，创建权限集后会默认包含一个和权限集key相同的KEY类型权限，主要用来进行权限集查询。

权限集与权限集直接可以进行绑定。当A权限集绑定了B权限集，目标对象拥有A权限集时，则默认也拥有B权限集。绑定关系可设定多个。

```
demo_fib.build do
  # 通过参数定义
  # action 定义action类权限
  # url 定义url类权限
  # key 定义key类权限
  # bind 绑定其他权限集
  # display 是否公开
  add :permission1, "Permission1",
    action: [[DemoController, :index]],
    url: ["demo/list", "demo/topic"],
    key: [:permission1_key1, :permission1_key2],
    bind: :permission2,
    display: true

  # 或者
  # 通过proc定义
  add :permission1, "Permission1" do
    def_action DemoController, :show do |user, request|
      # 扩展权限验证，额外进行权限判断
      user.demo.id == request.params[:id]
    end

    def_url "demo/list" do |user, request|
      # True or False
    end

    def_key :permission1_key1 do |user, obj|
      # obj为进行key判断时自定义传入的对象类型
    end

    # 开关是否公开
    display_on
    # or
    display_off

    # 绑定其他权限集
    bind_permission :permission2
  end
end
```

### 4. 设定权限管理目标模块

该功能当前只支持Rails框架

在需要被管理的ActiveRecord::Base子类中调用`fib_targeter! :demo`指定该类属于之前定义的权限系统。

```ruby
class Role < ActiveRecord::Base
  fib_targeter! :demo
end

class User < ActiveRecord::Base
  belongs_to :role

  # 指定该类的权限继承于某一关系对象, 需要该对象的类也定义了`fib_targeter! :demo`
  # 如没有指定inherit，默认继承于demo_fib, 权限范围为全部权限集
  fib_targeter! :demo, inherit: :role
end
```

然后当前类对象便可以进行权限管理
```ruby
u = User.first

u.permissions               # 获取权限
u.permissions_info          # 获取权限信息 [[:key, :name]]
u.permissions_scope         # 获取权限范围
u.save_permissions          # 保存当前权限
u.create_permissions(*keys) # 通过传入的keys创建权限，保存
u.new_permissions(*keys)    # 通过传入的keys创建权限，不保存
u.add_permissions(*keys)    # 添加权限，保存
u.del_permissions(*keys)    # 删除权限，保存
u.clear_permissions         # 清空权限，保存
```

### 5. 设定权限验证入口

该功能当前只支持Rails框架

在需要对权限进行验证的ActionController::Base子类中调用`fib_controller! :demo`指定从该入口进行权限验证

所有通过该入口进入的请求都会对`current_user`进行权限系统验证。请确保在该Controller中可以调用`current_user`方法

```ruby
class DemoController < ActionController::Base
  fib_controller! :demo

  def current_user
    # 查找当前用户的方法
  end
end
```

### 6. 权限验证说明

如果当前请求的action和url并未在权限系统中定义，则会默认通过验证，并提示当前请求权限未被定义

如果当前请求的action和url已定义但当前用户不拥有该权限，则返回401

对于key类型的权限，提供了一组dsl方法进行验证

```erb
<% if can?(:permission1_key2) && can?(:permission1_key1, obj) %>
  <p>1</p>
<% elsif cannot? :permission1 %>
  <p>2</p>
<% end %>
```

## TODO

- 优化查询

## BUG?

如果发现任何问题欢迎[提交Issue](https://github.com/Warrenoo/fibman/issues)或者Fork项目并创建Pull Requests

