require "forwardable"
require "active_support/all"

require "fib/railtie" if defined? Rails

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

require "fib/additions/container_addition"
require "fib/additions/targeter_addition"
require "fib/additions/rails_controller_addition"
require "fib/additions/dsl_addition"

module Fib
  extend SingleForwardable
  def_delegators Fib::Container, :new, :ls
end
