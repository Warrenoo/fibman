module Fibman
  class Element
    attr_reader :type, :core, :condition, :permission_key
    TYPE = %w(key action url).freeze

    def initialize type, core, condition=->(*args){}
      raise UnValidElementType, "current type -> #{type}, type need in (#{TYPE.join(", ")})!" unless TYPE.include? type
      @type = type
      @core = core
      raise ParameterIsNotValid, "Condition must belong to Proc!" unless condition.nil? || condition.is_a?(Proc)
      @condition = condition || ->(*args){}
    end

    def set_permission permission
      @permission_key = permission.is_a?(Fibman::Permission) ? permission.key : permission
    end

    def pass_condition? *args
      return true if condition.nil?
      condition[*args] != false
    end

    class << self
      def create_key key, &block
        new "key", key, block
      end

      def create_action controller, action, &block
        new "action", {controller: controller.to_s, action: action.to_s}, block
      end

      def create_url url, &block
        new "url", url, block
      end
    end
  end
end
