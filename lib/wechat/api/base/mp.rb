module Wechat::Api::Base::Mp
  MP_BASE = 'https://mp.weixin.qq.com/cgi-bin/'

  def qrcode(ticket)
    client.get 'showqrcode', params: { ticket: ticket }, as: :file
  end

end
