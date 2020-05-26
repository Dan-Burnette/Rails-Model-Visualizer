require_relative "application_service"
require_relative "../models/association"

class ExtractAssociationDefinitions < ApplicationService

  def initialize(file_content)
    @lines = file_content.split("\n")
  end

  def call
    association_definition_start_lines.map do |start_line|
      lines = association_lines(start_line)
      combine_multiline_associations_to_single_line(lines)
    end
  end

  private

  def association_definition_start_lines
    @lines.select { |line| defines_association?(line) }
  end

  def defines_association?(line)
    return false if line.empty?
    first_word = line.split(' ')[0]
    Association::TYPES.any? { |type | first_word == type }
  end

  def association_lines(definition_start_line)
    association_lines = []

    current_line = definition_start_line
    while line_ends_with_comma?(current_line)
      association_lines << current_line
      current_line = next_line(current_line)
    end

    association_lines << current_line
    association_lines
  end

  def line_ends_with_comma?(line)
    line.strip[-1] == ","
  end

  def next_line(current_line)
    next_index = @lines.index(current_line) + 1
    @lines[next_index]
  end

  def combine_multiline_associations_to_single_line(lines)
    lines.join(" ")
  end

end
