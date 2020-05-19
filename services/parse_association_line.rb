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
    if @line_terms.include?("class_name")
      option("class_name").downcase
    elsif @line_terms.include?("source")
      option("source")
    else
      @line_terms[1].singularize
    end
  end

  def through_model
    return nil if !@line_terms.include?("through")
    through_term_index = @line_terms.index("through")
    @line_terms[through_term_index + 1]
  end

  def option(name)
    term_index = @line_terms.index(name)
    @line_terms[term_index + 1].downcase
  end

end
