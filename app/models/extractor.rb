class Extractor < ApplicationRecord
  include RailsWechat::Extractor
end unless defined? Extractor
