class Extractor < ApplicationRecord
  
  def scan_regexp
    /#{name}[^#{item_separator}]+/
  end
  
end unless defined? Extractor
