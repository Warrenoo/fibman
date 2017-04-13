module Fib
  class Element
    attr_accessor :type, :core, :condition, :desc
    TYPE = %w(key action url).freeze

    def initialize(type, core, desc, condition=nil)
      @type = TYPE.include? type ? type : TYPE.first

      case @type
      when 'key'
      when 'action'
      when 'url'
      end

      @condition = condition
      Fib::Element.set_element(self)
    end

    class << self
      attr_accessor :all_elements

      def all_elements
        @all_elements ||= ElementPackage.new
      end

      def set_element(element)
        all_actions.add(element)
      end

      def can_if(model, actions, &block)
        return unless block_given?
        return unless actions.is_a?(Array) && !actions.empty?
        actions.each do |a|
          next unless all_actions[model.to_s] && all_actions[model.to_s][a.to_s]
          action_record = all_actions[model.to_s][a.to_s]
          action_record.condition = block if action_record && action_record.is_a?(Fib::Action)
        end
      end
    end
  end
end
