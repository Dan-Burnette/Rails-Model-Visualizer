class Association
  attr_reader :type, :from_model, :to_model, :through_model

  TYPES = ["belongs_to", "has_one", "has_many", "has_and_belongs_to_many"]

  def initialize(type, from_model, to_model, through_model)
    @type = type
    @from_model = from_model
    @to_model = to_model
    @through_model = through_model
  end

end
