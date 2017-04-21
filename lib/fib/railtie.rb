module Fib
  class Railtie < Rails::Railtie
    initializer "fib.initialize_dsl" do
      ActiveSupport.on_load(:action_controller) do
        include Fib::Additions::ControllerDslAddition
      end

      ActiveSupport.on_load(:active_record) do
        include Fib::Additions::TargeterDslAddition
      end
    end
  end
end
