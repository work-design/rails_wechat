module Wechat
  class Agent < ApplicationRecord
    self.table_name = 'wechat_corps'
    include Model::Agent
  end
end
