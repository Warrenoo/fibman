module Fib
  class UnDefinedModel < RuntimeError; end
  class MissParameter < RuntimeError; end
  class ParameterIsNotValid < RuntimeError; end
  class RoleIsNotFind < RuntimeError; end
  class UserClassIsNotFind < RuntimeError; end
  class PermissionIsNotFind < RuntimeError; end
end
