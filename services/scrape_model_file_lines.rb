class ScrapeModelFileLines < ApplicationService

  # TODO: Get via github api instead of scraper;
  # scraping in inherently not future proof as they may change their HTML setup
  # on github, ruining this code in the future.

  def initialize(model_urls)
    @urls = model_urls
  end

  def call
    result = {}
    @urls.each { |url| result[model_name(url)] = scrape_lines(url) }
    result
  end

  private

  def model_name(url)
    url.split('/').last.gsub(".rb", "")
  end

  def scrape_lines(url)
    scraped_data = Wombat.crawl do
      base_url url
      lines({css: ".js-file-line"}, :list)
    end

    scraped_data["lines"]
  end

end
