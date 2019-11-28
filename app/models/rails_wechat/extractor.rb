module RailsWechat::Extractor
  extend ActiveSupport::Concern
  included do
    attribute :name, :string
    attribute :prefix, :string
    attribute :suffix, :string
    attribute :more, :boolean, default: false

    belongs_to :organ, optional: true  # for SaaS
  end
  
  def scan_regexp
    if more
      /(?<=#{prefix}).*(?=#{suffix})/
    else
      /(?<=#{prefix}).*?(?=#{suffix})/
    end
  end

end

