require_relative "../models/association"

class ExtractModelAssociations < ApplicationService

  def initialize(models_to_file_lines)
    @models_to_file_lines = models_to_file_lines
  end

  def call
    models_to_associations = {}
    @models_to_file_lines.each do |model, lines|
      models_to_associations[model] = association_lines(lines).map do |line|
        Association.new(
          parse_type(line),
          model,
          parse_to_model(line),
          parse_through_model(line)
        )
      end
    end
    models_to_associations
  end

  private

  def association_lines(lines)
    lines.select { |l| defines_association?(l) }
  end

  def defines_association?(line)
    return false if line.empty?
    first_word = line.split(' ')[0]
    association_roots.any? { |root| first_word.include? root }
  end

  def association_roots
    ["belongs_to", "has_one", "has_many"]
  end

  #TODO SPECS FOR THESE DIFFERENT SYNTAXES!!!!
  #
  #
  # Ex: "association_type :to_model ..."
  def parse_type(line)
    line.split(" ")[0]
  end

  # Ex: "association_type :to_model ..."
  def parse_to_model(line)
    line.split(" ")[1].delete(":,")
  end

  # Hashrocket Syntax Ex:
  # "association_type :to_model, :through => :through_model ..."
  # Hash Syntax Ex:
  # "association_type :to_model, through: :through_model"
  def parse_through_model(line)
    return nil if !line.include?("through")
    line.split(" ")[3].delete(":")
  end

  # Hashrocket Syntax Ex:
  # "has_many :to_model, :through => :through_model, :source => :source_model"
  # Hash Syntax Ex:
  # "has_many :to_model, through: :through_model, source: :source_model"
  def parse_source_model(line)
    return nil if !line.include("source")
    line.split(" ")
  end

end
