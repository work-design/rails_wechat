module Wechat
  class OldApp < ApplicationRecord
    self.table_name = 'wechat_apps'
    encrypts :secret

  end
end
