# Extend ActiveRecord::Base with the partially valid extension module.
module ActiveRecord
  class Base
    include PartiallyValid
  end
end
