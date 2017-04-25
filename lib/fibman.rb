require "forwardable"
require "active_support/all"

require "fibman/railtie" if defined? Rails

require "fibman/config"
require "fibman/container"
require "fibman/element"
require "fibman/element_package"
require "fibman/error"
require "fibman/fpa"
require "fibman/permission"
require "fibman/permissions_collection"
require "fibman/trie"
require "fibman/version"

require "fibman/additions/container_addition"
require "fibman/additions/targeter_addition"
require "fibman/additions/rails_controller_addition"
require "fibman/additions/dsl_addition"

module Fibman
  extend SingleForwardable
  def_delegators Fibman::Container, :new, :ls
end
