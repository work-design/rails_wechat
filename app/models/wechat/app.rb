module Wechat
  class App < ApplicationRecord
    include Model::App
    include Model::AppSync
  end
end
