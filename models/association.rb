class Association
  attr_reader :type, :from_model, :to_model, :through_model

  def initialize(type, from_model, to_model, through_model)
    @type = type
    @from_model = from_model
    @to_model = to_model
    @through_model = through_model
  end

end
