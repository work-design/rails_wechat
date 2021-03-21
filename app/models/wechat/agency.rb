module Wechat
  class Agency < ApplicationRecord
    include Model::Agency
    include Model::AppSync
  end
end
