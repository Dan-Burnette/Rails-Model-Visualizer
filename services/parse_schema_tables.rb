require_relative "application_service"

class ParseSchemaTables < ApplicationService

  def initialize(schema_content)
    @lines = schema_content.split("\n")
  end

  def call
    table_models_to_column_lines
  end

  private

  def table_models_to_column_lines
    table_definition_lines.inject({}) do |result, definition_line|
      table_model_name = table_model_name(definition_line)
      column_lines = table_column_lines(definition_line)
      result[table_model_name] = column_lines
      result
    end
  end

  def table_definition_lines
    @lines.select { |l| l.include?("create_table") }
  end

  def table_model_name(definition_line)
    terms = definition_line.split(" ")
    name = terms[1].delete(",'\"")
    name.singularize
  end

  def table_column_lines(definition_line)
    column_lines = []

    current_line = next_line(definition_line)
    while current_line.include?("t.")
      column_lines << current_line
      current_line = next_line(current_line)
    end

    column_lines
  end

  def next_line(current_line)
    next_index = @lines.index(current_line) + 1
    @lines[next_index]
  end

end
