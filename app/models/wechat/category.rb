module Wechat
  class Category < ApplicationRecord
    include Model::Category
    include Com::Ext::Taxon
  end
end
