module Wechat::Api
  module Work::Kf
    BASE = 'https://qyapi.weixin.qq.com/cgi-bin/kf/'

    def accounts
      post 'account/list', origin: BASE
    end

    def account_link(open_kfid, **options)
      post 'add_contact_way', open_kfid: open_kfid, origin: BASE, **options
    end

    def account_add()
      post 'account/add'
    end

  end
end

