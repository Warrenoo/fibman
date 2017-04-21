module Fib
  module Additions
    module RailsControllerAddition
      extend ActiveSupport::Concern
      include Fib::Additions::ContainerAddition

      included do
        before_action :fib_include_validation

        rescue_from Fib::UnPassPermissionValidation, with: :handle_fib_permission_error
      end

      private

      def handle_fib_permission_error
        render status: 401, plain: "No permission" and return
      end

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

      # 如果该请求访问未在权限系统中设置
      # 通过并提示
      def fib_include_validation
        if fib_container.permissions.find_action(self.class.name, self.action_name) || fib_container.permissions.find_url(request.path)
          fib_url_validation
          fib_action_validation
        else
          # TODO 设定提示策略
        end
      end
    end
  end
end
