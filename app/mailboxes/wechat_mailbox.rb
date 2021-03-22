class WechatMailbox < ApplicationMailbox

  def process
    html = Nokogiri::HTML(mail.body.to_s)
    if forwarder
      forwarder.email_code = html.search('p.mmsgLetterDigital')[0]&.inner_text
      forwarder.save
    end
  end

  def forwarder
    return @forwarder if defined? @forwarder
    ident = mail.to[0].to_s.split('@')[0]
    @forwarder = Register.find_by(mobile: ident)
  end

end
