class AttachmentMailbox < ApplicationMailbox

  def process
    html = Nokogiri::HTML(mail.body.to_s)
  end

  def forwarder
    return @forwarder if defined? @forwarder
    ident = mail.to[0].to_s.split('@')[0]
    @forwarder = Wechat::Register.find_by(mobile: ident)
  end

end
