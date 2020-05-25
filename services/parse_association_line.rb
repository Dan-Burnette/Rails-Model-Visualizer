require "active_support/inflector"
require_relative "application_service"
require_relative "../models/association"

class ParseAssociationLine < ApplicationService

  def initialize(model, association_line)
    @model = model
    @line_terms = parse_terms(association_line)
  end

  def call
    Association.new(type, @model, to_model, through_model, polymorphic?)
  end

  private

  def parse_terms(line)
    raw_terms = line.delete("=>,'\"").split(" ")
    raw_terms.map { |t| t.delete_prefix(":").delete_suffix(":") }
  end

  def type
    @line_terms[0]
  end

  def to_model
    if @line_terms.include?("class_name")
      option("class_name").classify
    elsif @line_terms.include?("source")
      option("source").classify
    else
      to_model_term.classify
    end
  end

  def to_model_term
    @line_terms[1]
  end

  def through_model
    return nil if !@line_terms.include?("through")
    through_term_index = @line_terms.index("through")
    @line_terms[through_term_index + 1].classify
  end

  def polymorphic?
    return false if !@line_terms.include?("polymorphic")
    option("polymorphic") == "true"
  end

  def option(name)
    term_index = @line_terms.index(name)
    @line_terms[term_index + 1]
  end

  def namespaced?
    @model.include?("::")
  end

  def namespace
    @model.split("::")[0...-1].join("::")
  end

end
