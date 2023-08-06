module Wechat
  class PublicApp < App
    include Model::App::PublicApp
    include Inner::PublicApp
  end
end
