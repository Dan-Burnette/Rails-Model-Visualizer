require "active_support/inflector"
require_relative "application_service"
require_relative "../models/association"

class ParseAssociationLine < ApplicationService

  def initialize(model, association_line)
    @model = model
    @line = association_line
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
    @line.split(" ")[0]
  end

  def parse_to_model
    @line.split(" ")[1].delete(":,").singularize
  end

  def parse_through_model
    return nil if !@line.include?("through")
    terms = @line.delete("=>:,").split(" ")
    through_piece_index = terms.index { |term| term == "through" }
    terms[through_piece_index + 1]
  end

end
