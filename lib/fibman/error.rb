module Fibman
  class UnValidElementType < RuntimeError; end
  class UnDefinedModel < RuntimeError; end
  class MissParameter < RuntimeError; end
  class ParameterIsNotValid < RuntimeError; end
  class RoleIsNotFind < RuntimeError; end
  class UserClassIsNotFind < RuntimeError; end
  class PermissionIsNotFind < RuntimeError; end
  class RpaIsNotHandle < RuntimeError; end
  class UnPassPermissionValidation < RuntimeError; end
  class UnSetTargeterIdentify < RuntimeError; end
end
