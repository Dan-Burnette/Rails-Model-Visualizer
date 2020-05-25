class Association
  attr_reader :type, :from_model, :to_model, :through_model

  SINGULAR_TYPES = ["belongs_to", "has_one"]
  PLURAL_TYPES = ["has_many", "has_and_belongs_to_many"]
  TYPES = SINGULAR_TYPES + PLURAL_TYPES

  def initialize(type, from_model, to_model, through_model, polymorphic)
    @type = type
    @from_model = from_model
    @to_model = to_model
    @through_model = through_model
    @polymorphic = polymorphic
  end

  def label
    label = "#{@type}"
    if @through_model 
      label += " #{to_model_inflection} \n through #{@through_model.pluralize}"
    elsif @polymorphic
      label += " (polymorphic)"
    end
    label
  end

  private

  def to_model_inflection
    SINGULAR_TYPES.include?(@type) ? @to_model.singularize : @to_model.pluralize
  end

end
