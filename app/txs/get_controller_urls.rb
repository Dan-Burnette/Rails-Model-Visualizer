class GetControllerUrls

  def self.run(urls)
    controller_urls = []
    urls.each do |url| 
      if url.include?('controller.rb')
        controller_urls.push(url)
      end
    end
    controller_urls
  end

end