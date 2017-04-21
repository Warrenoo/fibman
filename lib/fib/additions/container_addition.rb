module Fib
  module Additions
    module ContainerAddition
      extend ActiveSupport::Concern

      included do
        class_attribute :__fib_container, instance_writer: false
      end

      def fib_container
        self.class.fib_container
      end

      class_methods do
        def fib_container
          return unless __fib_container
          self.__fib_container = __fib_container.is_a?(Fib::Container) ? __fib_container : (Fib.ls.find { |c| c.key == __fib_container } || __fib_container)
        end

        def fib_container= key
          self.__fib_container = key
        end
      end
    end
  end
end
