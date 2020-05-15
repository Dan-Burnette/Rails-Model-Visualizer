class GetSchemaData

  def self.run(schema_url)
    raw_schema_page = Wombat.crawl do
      base_url schema_url
      lines({css: ".js-file-line"}, :list)
    end

    db_schema_data = raw_schema_page["lines"]
    db_schema_data.delete('end')
    db_schema_data.delete("")
    #remove the lines with add index, we don't want unneeded details like that
    db_schema_data = db_schema_data.select {|x| x.include?("add_index") == false }

    #Find the indecies of where each table starts
    table_starts = db_schema_data.each_index.select {|i| db_schema_data[i].include?("create_table")}

    #Grabbing each table's data out
    all_table_data = []
    all_table_data_strs= []
    model_to_data = {}
    table_starts.each_with_index do |x,i|
      first = x
      last = table_starts[i+1]
      if last
        table_data = db_schema_data[first...last]
      else
        table_data = db_schema_data[first..-1]
      end

      model_name = table_data[0].split()[1].tr!('"', '')
      model_name = model_name.delete(',')
      model_name = model_name.singularize
  
      #remove the "create_table first element"
      table_data = table_data[1..-1]

      table_data_str = '<b>Schema</b><br/>'
      table_data.each do |d|
        table_data_str += d.to_s + '<br/>'
        table_data_str.gsub! /"/, ' '
      end
      all_table_data_strs.push(table_data_str)
      all_table_data.push(table_data)
      model_to_data.store(model_name, table_data_str)
    end

    model_to_data
  end

end
