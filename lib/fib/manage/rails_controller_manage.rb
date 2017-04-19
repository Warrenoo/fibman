module Fib
  module Manage
    module RailsControllerManage
      extend ActiveSupport::Concern

      included do
        before_action :fib_url_validation
        before_action :fib_action_validation
        before_action :fib_include_validation

        rescue_form Fib::UnPassPermissionValidation do
          render status: 403 and return
        end

        class << self; attr_accessor :fib_container; end
      end

      private

      # 验证url权限
      def fib_url_validation
        url_element = current_user.permissions.find_url(request.path)

        unless url_element && url_element.pass_condition?(current_user, request)
          raise Fib::UnPassPermissionValidation
        end
      end

      # 验证action权限
      def fib_action_validation
        controller = self.class.name
        action = self.action_name

        action_element = current_user.permissions.find_action(controller, action)

        unless action_element && action_element.pass_condition?(current_user, request)
          raise Fib::UnPassPermissionValidation
        end
      end

      # 如果该请求在权限系统中设置
      # 通过请求并提式
      def fib_include_validation
        unless fib_container.permissions.find_action(self.class.name, self.action_name) || fib_container.permissions.find_url(request.path)
          # TODO 设定提示策略
        end
      end

      def fib_container
        self.class.fib_container
      end
    end
  end
end
