module Wechat::Api
  module Base::Datacube
    BASE = 'https://api.weixin.qq.com/datacube/'

    def getusersummary(begin_date, end_date)
      post 'getusersummary', begin_date: begin_date, end_date: end_date, base: BASE
    end

    def getusercumulate(begin_date, end_date)
      post 'getusercumulate', begin_date: begin_date, end_date: end_date, base: BASE
    end

  end
end
