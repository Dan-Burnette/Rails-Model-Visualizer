class GetControllerActions

  def self.run(controller_urls)
    controllers = {}

    controller_urls.each do |controller_url|
      name = controller_url.split('/')[-1].split('_')[0]
      controller_actions = []
      raw = Wombat.crawl do
        base_url controller_url
        data({css: ".js-file-line"}, :list)
      end

      raw_data = raw["data"]
      raw_data.each do |item|
        #Get non-commented lines with def in them
        if item.include?('def ') && !item.include?('#')
          action = item.split[1]
          controller_actions.push(action)
        end
      end
      controllers.store(name, controller_actions)
    end
    controllers
  end

end