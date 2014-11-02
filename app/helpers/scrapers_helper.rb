module ScrapersHelper
 
  def inline_svg(path)
    file = File.open("app/assets/images/#{path}", "rb")
    raw file.read
  end


  
end
