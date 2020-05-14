class GetModelAssociations

  def self.run(urls)
    all_relationships = []
    urls.each do |url|
      lines = Wombat.crawl do 
        base_url url
        data({css: ".js-file-line"}, :list)
      end

      lines = lines["data"]
      relationships = []

      #Filter out bad relationships
      lines.each do |line|
        line_split = line.split(' ')
        #eliminating lines such as "attachment_fake_belongs_to_group(a)"
        #23 is the length of has_and_belongs_to_many, the biggest relationship
        if (line_split[0] != nil && line_split[0].length <= 23)
          if (line_split[0].include?("belongs_to") || line_split[0].include?("has_one") ||
              line_split[0].include?("has_many") || line_split[0].include?("belongs_to"))
            if (!line.include?("validates") && !line.include?('#'))
              relationships.push(line)
            end
          end 
        end
      end
      all_relationships.push(relationships)
    end
    all_relationships
  end

end
