# Add partial validation to ActiveRecord model objects.
#
# Example: Assume name, address, and phone number are all required
# fields on a Person model.
#
#   bill = Person.new
#   bill.should_be_partially_valid_on :name, :address
#   bill.partially_valid?  #=> false (name and address are invalid)
#
#   bill.name = "Bill"
#   bill.address = "Home Address"
#   bill.partially_valid?  #=> true  (now name and address are valid)
#
#   bill.should_be_partially_valid_on :phone_number
#   bill.partially_valid?  #=> false  (fails now because phone number is checked)
#
# After invoking :partially_valid?, the errors object will contain
# only errors referencing attributes declared to be considered for
# partial validation.
#
# The :valid? method continues to work as before.
#
module PartiallyValid
  # List of attributes that are checked for partial validation.
  def partially_valid_attributes
    @partially_valid_attributes ||= []
  end
  
  # Clear the list of attributes used in partial validation.
  def partially_valid_clear
    @partially_valid_attributes = []
  end
  
  # Declare that the list of attributes should be added to the list
  # checked for partial validation. The attribute names may be
  # strings or symbols.
  def should_be_partially_valid_on(*attrs)
    attrs.each do |attr_name|
      partially_valid_attributes << attr_name.to_s
    end
    partially_valid_attributes.uniq!
  end
  
  # Is the model valid on the attributes declared to be checked for
  # partial validation? Errors on non-checked attributes are removed
  # from the error list not not considered as errors for the purpose
  # of partial validation.
  def partially_valid?
    valid?
    pertinent_errors = []
    errors.each do |attr, msg|
      pertinent_errors << [attr, msg] if partially_valid_attributes.include?(attr.to_s)
    end
    errors.clear
    pertinent_errors.each do |attr, msg|
      errors.add(attr, msg)
    end
    errors.empty?
  end
end
