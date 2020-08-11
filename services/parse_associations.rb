require_relative 'application_service'
require_relative 'extract_association_definitions'
require_relative 'parse_association_definition'

class ParseAssociations < ApplicationService
  def initialize(model_classes, model, file_content)
    @model_classes = model_classes
    @model = model
    @file_content = file_content
  end

  def call
    definitions = ExtractAssociationDefinitions.call(@file_content)
    definitions.map do |d|
      ParseAssociationDefinition.call(@model_classes, @model, d)
    end
  end
end
