module Fib
  module Additions
    module RailsControllerAddition
      extend ActiveSupport::Concern
      include Fib::Additions::ContainerAddition

      included do
        before_action :fib_include_validation
        helper_method :can?, :cannot?

        delegate :permissions, to: :current_user

        rescue_from Fib::UnPassPermissionValidation, with: :handle_fib_permission_error
      end

      def can? key, obj=nil
        key_element = permissions.find_key(key)
        key_element.present? && key_element.pass_condition?(current_user, obj)
      end

      def cannot? key, obj=nil
        !can?(key, obj)
      end

      private

      def handle_fib_permission_error
        render status: 401, plain: "No permission" and return
      end

      # 验证url权限
      def fib_url_validation
        url_element = permissions.find_url(request.path)

        unless url_element && url_element.pass_condition?(current_user, request)
          raise Fib::UnPassPermissionValidation
        end
      end

      # 验证action权限
      def fib_action_validation
        controller = self.class.name
        action = self.action_name

        action_element = permissions.find_action(controller, action)

        unless action_element && action_element.pass_condition?(current_user, request)
          raise Fib::UnPassPermissionValidation
        end
      end

      # 如果该请求访问未在权限系统中设置
      # 通过并提示
      def fib_include_validation
        has_action = fib_container.permissions.find_action(self.class.name, self.action_name).present?
        has_url = fib_container.permissions.find_url(request.path).present?

        fib_action_validation if has_action
        fib_url_validation if has_url

        unless has_action || has_url
          # TODO 进行提示 策略待定
        end
      end
    end
  end
end
