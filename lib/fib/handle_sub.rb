module Fib
  module HandleSub
    class << self
      HANDLE_BODY = %w(reload_permissions).freeze

      def handle(body)
        event, *data = body.split(":")
        send(event, *data) if HANDLE_BODY.include? event
      end

      def reload_permissions(type, key)
        case type
        when "role"
          record = Fib.get_role_by_name(key)
          if record
            record.reload_permissions!
            record.final_permissions
          end
        end
      end
    end
  end
end
