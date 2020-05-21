require_relative "application_service"
require_relative "extract_association_lines"
require_relative "parse_association_line"

class ParseAssociations < ApplicationService

  def initialize(model, file_content)
    @model = model
    @content = file_content
  end

  def call
    lines = ExtractAssociationLines.call(@content) 
    lines.map { |line| ParseAssociationLine.call(@model, line) }
  end

end
