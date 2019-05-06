class Extractor < ApplicationRecord
  
  enum direction: {
    prefix: 'prefix',
    suffix: 'suffix'
  }
  
  def scan_regexp
    if prefix?
      /#{match_value}[^#{separator}]+/u
    elsif suffix?
      /#{match_value}[^#{separator}]+/u
    end
  end
  
end unless defined? Extractor
