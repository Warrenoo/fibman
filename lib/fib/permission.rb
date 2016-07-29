module Fib
  # Permission Particle
  class Permission
    attr_accessor :model, :model_name, :action_name, :action_package, :explain, :bind, :display

    def initialize(model, options)
      raise UnDefinedModel, "Can't find model, Please confim defined it!" unless defined? model
      @model = model.to_s.freeze
      @model_name = options[:model_name] || "undefined"
      raise MissParameter, "missing the action_name with permission init!" unless options.key?(:action_name)
      @action_name = options[:action_name].to_s.freeze
      @action_package = (options[:action_package].map(&:to_s) || [@action_name]).map { |n| Fib::Action.new @model, n }
      @explain = options[:explain] || "undefined"
      @bind = options[:bind] || Fib::PermissionsCollection.new
      @display = options.key?(:display) ? options[:display] : true
    end

  end
end
