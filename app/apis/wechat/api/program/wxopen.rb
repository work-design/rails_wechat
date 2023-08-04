module Wechat::Api
  module Program::Wxopen
    BASE = 'https://api.weixin.qq.com/cgi-bin/wxopen/'

    def categories
      r = get 'getallcategories', origin: BASE
      if r['errcode'] == 0
        r.dig('categories_list', 'categories')
      else
        r
      end
    end

    def category
      get 'getcategory', origin: BASE
    end

    def add_category(categories)
      post 'addcategory', categories: categories, origin: BASE
    end

  end
end

