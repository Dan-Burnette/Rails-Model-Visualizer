class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  @directory_urls = []
  def scrape_directory_urls(github_url)
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
        scrape_directory_urls(d)
      end

    #No deeper directories to check out , scrape the files 
    else
      return
    end

  end

  def scrape_file_urls(github_url)
    #Get file URLs
    raw_data = Wombat.crawl do
      base_url github_url
      data({css: ".css-truncate"}, :list)
    end

    raw_data.each do |item|
      model_and_extension = item.split('.')
      if (model_and_extension.include?('rb'))
        model = model_and_extension[0]
        @models.push(model)
        model_url = start_url + '/' + model_and_extension.join('.')
        @model_urls.push(model_url)
      end
    end

  end


end
