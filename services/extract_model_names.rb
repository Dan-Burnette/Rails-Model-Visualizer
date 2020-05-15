class ExtractModelNames < ApplicationService

  def initialize(lines)
    @lines = lines
  end

  def call
    model_definitions.map { |definiton| parse_model_name(definition) }
  end

  private

  def model_definitions
    @lines.select { |l| l.include?("class") }
  end

  # def extends_default_model_class?(definition)
  #   definition.include?("ActiveRecord::Base") ||
  #     definition.include?("ApplicationRecord")
  # end
  #
  # def extends_other_model_class?(definition)
  #   !extends_default_model_class?(definition) && definition.include?("<")
  # end

  def parse_model_name(definition)
    definition.split("<")[0].split()[-1].split(/(?=[A-Z])/).join("_").downcase
  end

  # def parse_extended_model_name(definition)
  #   definition.split(' ')[-1].tableize.singularize.downcase
  # end

end
