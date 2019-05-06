module RailsWechat::Extractor
  extend ActiveSupport::Concern
  included do
    attribute :more, :boolean, default: false
  end
  
  def scan_regexp
    if more
      /(?<=#{prefix}).*(?=#{suffix})/
    else
      /(?<=#{prefix}).*?(?=#{suffix})/
    end
  end

end

