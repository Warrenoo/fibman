module Fib
  module Additions
    module ControllerDslAddition
      extend ActiveSupport::Concern
      class_methods do
        def fib_controller! key
          include Fib::Additions::RailsControllerAddition
          self.fib_container = key
        end
      end
    end

    module TargeterDslAddition
      extend ActiveSupport::Concern
      class_methods do
        def fib_targeter! key
          include Fib::Additions::TargeterAddition
          self.fib_container = key
        end
      end
    end
  end
end
