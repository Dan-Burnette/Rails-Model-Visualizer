require "active_support/inflector"
require_relative "application_service"
require_relative "../models/association"

class ParseAssociationLine < ApplicationService

  def initialize(model, association_line)
    @model = model
    @line_terms = association_line.delete("=>:,'\"").split(" ")
  end

  def call
    Association.new(
      parse_type,
      @model,
      parse_to_model,
      parse_through_model
    )
  end

  private

  def parse_type
    @line_terms[0]
  end

  def parse_to_model
    if @line_terms.include?("class_name")
      class_name_index = @line_terms.index { |term| term == "class_name" }
      @line_terms[class_name_index + 1].downcase
    else
      @line_terms[1].singularize
    end
  end

  def parse_through_model
    return nil if !@line_terms.include?("through")
    through_piece_index = @line_terms.index { |term| term == "through" }
    @line_terms[through_piece_index + 1]
  end

end
