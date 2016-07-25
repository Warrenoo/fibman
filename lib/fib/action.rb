module Fib
  class Action
    attr_accessor :model, :action_name, :condition
    def initialize(model, action_name, condition=nil)
      @model = model
      @action_name = action_name
      @condition = condition

      Fib::Action.set_action(self)
    end

    class << self
      attr_accessor :all_actions

      def all_actions
        @all_actions ||= {}
      end

      def set_action(action)
        all_actions[action.model] ||= {}
        all_actions[action.model][action.action_name] = action
      end

      def can_if(model, actions, &block)
        return unless block_given?
        return unless actions.is_a?(Array) && actions.size > 0
        actions.each do |a|
          next unless all_actions[model.to_s] && all_actions[model.to_s][a.to_s]
          action_record = all_actions[model.to_s][a.to_s]
          action_record.condition = block if action_record && action_record.is_a?(Fib::Action)
        end
      end
    end
  end
end
