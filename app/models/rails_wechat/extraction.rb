module RailsWechat::Extraction
  extend ActiveSupport::Concern
  included do
    attribute :name, :string
    attribute :matched, :string
    
    belongs_to :extractor
    belongs_to :extractable, polymorphic: true
  end
  
end
