class ScrapeModelFileLines < ApplicationService

  # TODO: Get via github api instead of scraper;
  # scraping in inherently not future proof as they may change their HTML setup
  # on github, ruining this code in the future.

  def initialize(model_url)
    @url = model_url
    puts "url is " 
    puts @url.inspect
  end

  def call
    scrape_lines(@url)
  end

  private

  def scrape_lines(url)
    scraped_data = Wombat.crawl do
      base_url url
      lines({css: ".js-file-line"}, :list)
    end

    scraped_data["lines"]
  end

end
