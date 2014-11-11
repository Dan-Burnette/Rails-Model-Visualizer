class ApplicationController < ActionController::Base
  require "net/http"
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def scrape_all_urls(github_url)
    #Get directory URLS
    raw_directories = Wombat.crawl do
      base_url github_url
      data({css: ".js-directory-link"}, :list)
    end
    directories = raw_directories["data"]

    #We've got some more directories to check out
    if (directories.empty? == false)
      directories_to_check = []
      directories.each do |d|
        url = github_url + '/' + d
        @directory_urls.push(url)
        directories_to_check.push(url)
      end
      directories_to_check.each do |d|
        scrape_all_urls(d)
      end
    #BASE CASE - no deeper directories to check
    else
      return
    end
  end

  #Pass in a list of all URLs and it will find all the models and URLS
  def get_models_and_urls(url_array)
    url_array.each do |url|
      if (url.include?('.rb'))
        raw = Wombat.crawl do
          base_url url
          data({css: ".js-file-line"}, :list)
        end

        raw_data = raw["data"]
        raw_data.each do |item|
          if (item.include?('< ActiveRecord::Base'))
            model = item.split("<")[0].split()[-1].split(/(?=[A-Z])/).join("_").downcase
            @models.push(model)
            @model_urls.push(url)
            @models_that_extend_active_record_base.push(model)
          #Catch those models that inherit from a model which inherits from ActiveRecord::Base
          elsif (item.include?('<'))
            split_item = item.split(' ')
            extends_model = split_item[-1].tableize.singularize.downcase
            if (@models_that_extend_active_record_base.include?(extends_model))
              model = item.split("<")[0].split()[-1].split(/(?=[A-Z])/).join("_").downcase
              @models.push(model)
              @model_urls.push(url)
              @model_to_model_it_extends.store(model, extends_model)
            end
          end
        end
      end
    end
  end


  #For checking if the schema can be found
  def url_exist?(url_string)
    url = URI.parse(url_string)
    req = Net::HTTP.new(url.host, url.port)
    req.use_ssl = (url.scheme == 'https')
    path = url.path if url.path.present?
    res = req.request_head(path || '/')
    res.code != "404" # false if returns 404 - not found
  rescue Exception => e
    false # false if can't find the server
  end


end
