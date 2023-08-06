module Wechat
  class App < ApplicationRecord
    self.table_name = 'wechat_agencies'
    include Model::App
  end
end
