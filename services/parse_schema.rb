class ParseSchema < ApplicationService

  def initialize(schema_content)
    @lines = schema_content.split("\n")
  end

  def call
    # lines.delete('end')
    # lines.delete("")
    #remove the lines with add index, we don't want unneeded details like that
    # lines = lines.select {|x| x.include?("add_index") == false }

    table_start_lines = @lines.select { |l| l.include?("create_table") }
    all_tables_lines = table_start_lines.map do |start_line|
      table_lines = []

      index = @lines.index(start_line) + 1
      current_line = @lines[index]
      while current_line.include?("t.")
        table_lines << current_line
        index +=1
        current_line = @lines[index]
      end

      table_lines
    end

    model_to_data = {}
    all_table_data_strs= []
    all_tables_lines.each do |lines|
      puts "lines here"
      puts lines.inspect
      model_name = lines[0].split()[1].tr!('"', '')
      model_name = model_name.delete(',')
      model_name = model_name.singularize

      table_data_str = '<b>Schema</b><br/>'
      lines.each do |d|
        table_data_str += d.to_s + '<br/>'
        table_data_str.gsub! /"/, ' '
      end
      all_table_data_strs.push(table_data_str)
      model_to_data.store(model_name, table_data_str)
    end



    ######==========

    #Find the indecies of where each table starts
    # table_starts = lines.each_index.select { |i| lines[i].include?("create_table")}

    #Grabbing each table's data out
    # all_table_data = []
    # all_table_data_strs= []
    # model_to_data = {}
    # table_starts.each_with_index do |x,i|
    #   first = x
    #   last = table_starts[i+1]
    #   if last
    #     table_data = lines[first...last]
    #   else
    #     table_data = lines[first..-1]
    #   end
    #
    #   model_name = table_data[0].split()[1].tr!('"', '')
    #   model_name = model_name.delete(',')
    #   model_name = model_name.singularize
    #
    #   #remove the "create_table first element"
    #   table_data = table_data[1..-1]
    #
    #   table_data_str = '<b>Schema</b><br/>'
    #   table_data.each do |d|
    #     table_data_str += d.to_s + '<br/>'
    #     table_data_str.gsub! /"/, ' '
    #   end
    #   all_table_data_strs.push(table_data_str)
    #   all_table_data.push(table_data)
    #   model_to_data.store(model_name, table_data_str)
    # end

    model_to_data
  end

  private

  def table_definition_lines

  end

end
