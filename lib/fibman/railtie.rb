module Fibman
  class Railtie < Rails::Railtie
    initializer "fibman.initialize_dsl" do
      ActiveSupport.on_load(:action_controller) do
        include Fibman::Additions::ControllerDslAddition
      end

      ActiveSupport.on_load(:active_record) do
        include Fibman::Additions::TargeterDslAddition
      end
    end
  end
end
