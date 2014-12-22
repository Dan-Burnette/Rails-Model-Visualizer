class ScrapeAllUrls

   def self.run(github_url)
    directory_urls = []
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
        directory_urls.push(url)
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