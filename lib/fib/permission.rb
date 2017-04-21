# Permission Particle
module Fib
  class Permission
    extend Forwardable

    attr_reader :key, :name, :package, :explain, :bind, :display

    def_delegators :package, :append

    def initialize key, options={}
      @key = key.to_sym
      @name = options[:name] || key.to_s
      @package = options[:package] || Fib::ElementPackage.new
      @explain = options[:explain] || "undefined"
      @bind = options[:bind] || []
      @display = options.key?(:display) ? options[:display] : true
    end

    def def_action controller, action, &block
      @package << Fib::Element.create_action(controller, action, &block)
    end

    def def_url url, &block
      @package << Fib::Element.create_url(url, &block)
    end

    def def_key key, &block
      @package << Fib::Element.create_key(key, &block)
    end

    def display_on
      return unless bind.size == 0
      @display = true
    end

    def display_off
      @display = false
    end

    def bind_permission *permission_keys
      @bind = permission_keys.flatten
      display_off if bind.size > 0
    end

    def inject_elements_permission
      package.origin_elements.values.flatten.each do |e|
        e.set_permission self
      end
    end
  end
end
