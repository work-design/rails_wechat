class WechatMailbox < ApplicationMailbox

  def process
    html = Nokogiri::HTML(mail.body.to_s)
    forwarder.email_code = html.search('p.mmsgLetterDigital')[0]&.inner_text
    forwarder.save
  end

  def forwarder
    return @forwarder if defined? @forwarder
    ident = mail.to[0].to_s.split('@')[0]
    @forwarder = WechatRegister.find(ident)
  end

end
