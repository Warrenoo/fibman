module Fib
  module HandleSub
    class << self
      HANDLE_BODY = %w(reload_permissions).freeze

      def handle(body)
        p "permission_events recive: #{body}"
        send(body) if HANDLE_BODY.include? body
      end

      def reload_permissions
        Fib.all_roles.each{|r| r.reload_permissions! and r.final_permissions }
      end
    end
  end
end
