require "active_support/inflector"
require_relative "application_service"
require_relative "../models/association"

class ParseAssociationLine < ApplicationService

  def initialize(model, association_line)
    @model = model
    @line_terms = association_line.delete("=>:,'\"").split(" ")
  end

  def call
    Association.new(type, @model, to_model, through_model)
  end

  private

  def type
    @line_terms[0]
  end

  def to_model
    @line_terms.include?("class_name") ?
      class_name_model :
      @line_terms[1].singularize
  end

  def class_name_model
    class_name_index = @line_terms.index("class_name")
    @line_terms[class_name_index + 1].downcase
  end

  def through_model
    return nil if !@line_terms.include?("through")
    through_term_index = @line_terms.index("through")
    @line_terms[through_term_index + 1]
  end

end
