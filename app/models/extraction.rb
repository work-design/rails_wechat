class Extraction < ApplicationRecord
  belongs_to :extractor
  belongs_to :extractable, polymorphic: true
  
end unless defined? Extraction
