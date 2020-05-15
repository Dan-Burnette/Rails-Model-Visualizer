class ExtractModelAssociations < ApplicationService

  def initialize(lines)
    @lines = lines
  end

  def call
    all_relationships = []
    lines = Wombat.crawl do 
      base_url url
      the_lines({css: ".js-file-line"}, :list)
    end

    lines = lines["the_lines"]
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
      all_relationships.push(relationships)
    end
    all_relationships
  end
  private
end
