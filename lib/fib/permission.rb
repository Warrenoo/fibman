# Permission Particle
module Fib
  class Permission
    extend Forwardable

    attr_reader :key, :name, :package, :bind, :display
    attr_accessor :container

    def_delegators :package, :append

    def initialize key, options={}
      @key = key.to_sym
      @name = options[:name] || key.to_s
      @package = options[:package] || Fib::ElementPackage.new
      @bind = options[:bind] || []
      @display = options.key?(:display) ? options[:display] : true
    end

    def bind_packages
      return [] unless bind.present? || container.present?

      packages = []
      bind.each do |b|
        p = container.permissions.permissions[b]
        next unless p.present?
        packages << p.package
        packages << p.bind_packages
      end
      packages.flatten
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
      @display = true
    end

    def display_off
      @display = false
    end

    def bind_permission *permission_keys
      @bind << permission_keys.flatten.map(&:to_sym)
      @bind.flatten!.uniq!
    end

    def inject_elements_permission
      package.origin_elements.values.flatten.each do |e|
        e.set_permission self
      end
    end
  end
end
