class ExtractModelAssociations < ApplicationService

  def initialize(models_to_file_lines)
    @models_to_file_lines = models_to_file_lines
  end

  def call
    models_to_associations = {}
    @models_to_file_lines.each do |model, lines|
      models_to_associations[model] = associations(lines)
    end
    models_to_associations
  end

  private

  def associations(lines)
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

end
