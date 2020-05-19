class Association
  attr_reader :type, :from_model, :to_model, :through_model

  SINGLULAR_TYPES = ["belongs_to", "has_one"]
  PLURAL_TYPES = ["has_many", "has_and_belongs_to_many"]
  TYPES = SINGLULAR_TYPES + PLURAL_TYPES

  def initialize(type, from_model, to_model, through_model)
    @type = type
    @from_model = from_model
    @to_model = to_model
    @through_model = through_model
  end

  # def from_model
  #   singular_type? ? from_model.singularize : from_model.pluralize
  # end
  #
  # def to_model
  #   singular_type? ? to_model.singularize : to_model.pluralize
  # end

  private

  # def singular_type?
  #   SINGLULAR_TYPES.include?(type)
  # end

end
