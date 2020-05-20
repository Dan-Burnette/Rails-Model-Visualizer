class ParseSchema < ApplicationService

  def initialize(schema_content)
    @lines = schema_content.split("\n")
  end

  def call
    all_tables_lines =
      table_definition_lines.map { |def_line| table_content_lines(def_line) }

    table_to_data = {}
    all_tables_lines.each_with_index do |lines, i|
      table_name = table_definition_lines[i].split(" ")[1].delete(",'\"").singularize

      table_data_str = ""
      lines.each do |d|
        table_data_str += d
        # table_data_str.gsub! /"/, ' '
      end
      table_to_data.store(table_name, lines)
    end

    table_to_data
  end

  private

  def table_definition_lines
    @lines.select { |l| l.include?("create_table") }
  end

  def table_content_lines(definition_line)
    table_lines = []

    index = @lines.index(definition_line) + 1
    current_line = @lines[index]
    while current_line.include?("t.")
      table_lines << current_line
      index +=1
      current_line = @lines[index]
    end

    table_lines
  end

end
