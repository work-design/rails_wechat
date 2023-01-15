module Wechat
  class Agency < ApplicationRecord
    include Model::Agency
    include Inner::App
  end
end
