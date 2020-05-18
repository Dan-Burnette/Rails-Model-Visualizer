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

  #TODO SPECS FOR THESE DIFFERENT SYNTAXES!!!!
  #
  #
  # Ex: "association_type :to_model ..."
  def parse_type
    @line.split(" ")[0]
  end

  # Ex: "association_type :to_model ..."
  def parse_to_model
    @line.split(" ")[1].delete(":,")
  end

  # Hashrocket Syntax Ex:
  # "association_type :to_model, :through => :through_model ..."
  # Hash Syntax Ex:
  # "association_type :to_model, through: :through_model"
  def parse_through_model
    return nil if !@line.include?("through")
    @line.split(" ")[3].delete(":")
  end

  # Hashrocket Syntax Ex:
  # "has_many :to_model, :through => :through_model, :source => :source_model"
  # Hash Syntax Ex:
  # "has_many :to_model, through: :through_model, source: :source_model"
  def parse_source_model
    return nil if !@line.include("source")
    @line.split(" ")
  end

end
