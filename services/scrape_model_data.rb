require "active_support/all"
class ScrapeModelData < ApplicationService

  def initialize(model_urls)
    @urls = model_urls
    @models = []
    @models_that_extend_rails_default_model_class =  []
    @model_to_model_it_extends = {}
  end

  def call
    @urls.each do |url|
      model_definition = scrape_model_definition_line(url)
      model = parse_model_name(model_definition)
      @models.push(model)

      if extends_default_model_class?(model_definition)
        @models_that_extend_rails_default_model_class.push(model)
      elsif extends_other_model_class?(model_definition)
        extended_model = parse_extended_model_name(model_definition)
        if (@models_that_extend_rails_default_model_class.include?(extended_model))
          @model_to_model_it_extends.store(model, extended_model)
        end
      end
    end

    {models: @models, model_to_model_it_extends: @model_to_model_it_extends}
  end

  private

  def scrape_model_definition_line(url)
    scraped_data = Wombat.crawl do
      base_url url
      lines({css: ".js-file-line"}, :list)
    end

    scraped_data["lines"].find { |l| l.include?("class") }
  end

  def extends_default_model_class?(definition)
    definition.include?("ActiveRecord::Base") ||
      definition.include?("ApplicationRecord")
  end

  def extends_other_model_class?(definition)
    !extends_default_model_class?(definition) && definition.include?("<")
  end

  def parse_model_name(definition)
    definition.split("<")[0].split()[-1].split(/(?=[A-Z])/).join("_").downcase
  end

  def parse_extended_model_name(definition)
    definition.split(' ')[-1].tableize.singularize.downcase
  end

end
