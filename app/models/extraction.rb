class Extraction < ApplicationRecord
  include RailsWechat::Extraction
end unless defined? Extraction
