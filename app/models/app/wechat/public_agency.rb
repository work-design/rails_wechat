module Wechat
  class PublicAgency < Agency
    include Model::App::PublicAgency
    include Inner::PublicApp
  end
end
