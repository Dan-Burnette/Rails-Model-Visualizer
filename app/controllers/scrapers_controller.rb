class ScrapersController < ApplicationController
 # GENERATE A DIAGRAM OF A RAILS APP'S MODEL RELATIONSHIPS!

  def index
    @start_url = "https://github.com/Dan-Burnette/ScoreSettler/tree/master/app/models"

    @raw = Wombat.crawl do
      base_url "https://github.com/Dan-Burnette/ScoreSettler/tree/master/app/models"
      data({css: ".css-truncate"}, :list)
    end

    @models = []
    @model_urls = []
    @raw_data = @raw["data"]
    @raw_data.each do |item|
      model_and_extension = item.split('.')
      if (model_and_extension.include?('rb'))
        model = model_and_extension[0]
        @models.push(model)
        model_url = @start_url + '/' + model_and_extension.join('.')
        @model_urls.push(model_url)
      end
    end

    @all_lines = []
    @all_relationships = []
    @model_urls.each do |url|

      lines = Wombat.crawl do 
        base_url url
        data({css: ".js-file-line"}, :list)
      end

      lines = lines["data"]
      @all_lines.push(lines)

      relationships = []
      lines.each do |line|
        if (line.include?("belongs_to") || line.include?("has_one") ||
            line.include?("has_many") || line.include?("belongs_to"))
            relationships.push(line)
        end 
      end
      @all_relationships.push(relationships)

    end




    

  end
  
end
