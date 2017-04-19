require "forwardable"
require "active_support"

require "fib/config"
require "fib/container"
require "fib/element"
require "fib/element_package"
require "fib/error"
require "fib/fpa"
require "fib/handle_sub"
require "fib/permission"
require "fib/permissions_collection"
require "fib/trie"
require "fib/version"

require "fib/manage/targeter_manage"
require "fib/manage/rails_controller_manage"

module Fib
  extend SingleForwardable
  def_delegator Fib::Container, :new
end
