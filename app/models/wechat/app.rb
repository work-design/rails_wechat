module Wechat
  class App < ApplicationRecord
    include Model::App
    include Inner::App
  end
end
