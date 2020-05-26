require "active_support/inflector"
require_relative "application_service"

class ParseClassName < ApplicationService

  def initialize(file_content)
    @lines = file_content.split("\n")
  end

  def call
    build_namespaced_class_name
  end

  private

  def build_namespaced_class_name
    class_name = ""
    definition_lines.each_with_index do |definition, i|
      class_name += class_or_module_name(definition)
      class_name += "::" if definition_lines[i+1]
    end
    class_name
  end

  def class_or_module_name(definition_line)
    terms = definition_line.split(" ")
    terms[1].delete(",'\"")
  end

  # Identify the line where the main class definition begins. Skip over any
  # exception definitions, as it is common practice to define related exceptions
  # at the top of the file.
  def definition_line?(line)
    is_definition = line.include?("class ") || line.include?("module ") 
    error_definition = line.include?("Error") || line.include?("Exception")
    is_definition && !error_definition
  end

  def top_definition_line
    @lines.find { |line| definition_line?(line) }
  end

  def definition_lines
    definition_lines = []

    current_line = top_definition_line
    puts "top_definition_line"
    puts current_line.inspect
    while definition_line?(current_line)
      definition_lines << current_line
      current_line = next_line(current_line)
    end

    definition_lines
  end

  def next_line(current_line)
    next_index = @lines.index(current_line) + 1
    @lines[next_index]
  end

end
