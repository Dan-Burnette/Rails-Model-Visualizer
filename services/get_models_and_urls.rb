class GetModelsAndUrls

  def self.run(urls)

    models = []
    model_urls = []
    models_that_extend_active_record_base = []
    model_to_model_it_extends = {}

    urls.each do |url|
      puts "scraping model url..."
      puts url.inspect
      if (url.include?('.rb'))
        raw = Wombat.crawl do
          base_url url
          lines({css: ".js-file-line"}, :list)
        end

        raw_data = raw["lines"]
        raw_data.each do |item|
          if (item.include?('< ActiveRecord::Base'))
            model = item.split("<")[0].split()[-1].split(/(?=[A-Z])/).join("_").downcase
            models.push(model)
            model_urls.push(url)
            models_that_extend_active_record_base.push(model)
            #Catch those models that inherit from a model which inherits from ActiveRecord::Base
          elsif (item.include?('<'))
            split_item = item.split(' ')

            extends_model = split_item[-1].tableize.singularize.downcase
            if (models_that_extend_active_record_base.include?(extends_model))
              model = item.split("<")[0].split()[-1].split(/(?=[A-Z])/).join("_").downcase
              models.push(model)
              model_urls.push(url)
              model_to_model_it_extends.store(model, extends_model)
            end
          end
        end
      end
    end

    {models: models, model_urls: model_urls, model_to_model_it_extends: model_to_model_it_extends}

  end


end
