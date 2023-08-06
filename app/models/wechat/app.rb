module Wechat
  class App < ApplicationRecord
    self.name = 'wechat_agencies'
    include Model::App
  end
end
