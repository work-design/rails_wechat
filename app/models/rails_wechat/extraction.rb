module RailsWechat::Extraction
  extend ActiveSupport::Concern
  included do
    belongs_to :extractor
    belongs_to :extractable, polymorphic: true
  end
  
end
