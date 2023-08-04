module Wechat::Api
  module Program::Wxopen
    BASE = 'https://api.weixin.qq.com/cgi-bin/wxopen/'

    def categories
      get 'getallcategories', origin: BASE
    end

    def category
      get 'getcategory', origin: BASE
    end

    def add_category(categories)
      post 'addcategory', categories: categories, origin: BASE
    end

  end
end

