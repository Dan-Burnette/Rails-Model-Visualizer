class ScrapeAllUrls

   def self.run(directory_url)
    directory_or_file_urls = []

    #Get directory URLS
    raw_directories = Wombat.crawl do
      base_url directory_url
      urls({css: " .files .js-navigation-item a"}, :list)
    end

    directories = raw_directories["urls"]
    puts "raw_directories"
    puts raw_directories.inspect

    #We've got some more directories to check out
    if (directories.empty? == false)
      directories_to_check = []
      directories.each do |d|
        url = directory_url + '/' + d
        directory_or_file_urls.push(url)
        directories_to_check.push(url)
      end

      directories_to_check.each do |d|
        self.run(d)
      end
    #BASE CASE - no deeper directories to check
    else
      return
    end

   end

end
