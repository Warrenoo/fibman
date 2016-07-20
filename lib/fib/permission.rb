module Fib
  # Permission Particle
  class Permission
    attr_accessor :model, :action_name, :action_package, :explain

    def initialize(model, options)
      raise UnDefinedModel, "Can't find model, Please confim defined it!" unless defined? model
      @model = model.to_s.freeze
      raise MissParameter, "missing the action_name with permission init!" unless options.has_key?(:action_name)
      @action_name = options[:action_name].to_s.freeze
      @action_package = options[:action_package].map(&:to_s) || [@action_name]
      @expain = options[:explain] || "undefined"
    end
  end
end
