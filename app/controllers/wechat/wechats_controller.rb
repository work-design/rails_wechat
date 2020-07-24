class Wechat::WechatsController < ApplicationController
  skip_before_action :verify_authenticity_token, raise: false
  before_action :set_wechat_app, only: [:show, :create]
  before_action :verify_signature, only: [:show, :create]

  def show
    if @wechat_app.is_a?(WechatWork)
      echostr, _corp_id = Cipher.unpack(Cipher.decrypt(Base64.decode64(params[:echostr]), @wechat_app.encoding_aes_key))
      render plain: echostr
    else
      render plain: params[:echostr]
    end
  end

  def create
    received = Wechat::Message::Received.new(@wechat_app, request.raw_post)
    replied = received.reply
    replied.get_reply

    if replied.respond_to? :to_xml
      render plain: replied.to_xml
    else
      render plain: 'success'
    end

    ActiveSupport::Notifications.instrument 'wechat.responder.after_create', request: received.to_xml, response: replied&.to_xml
  end

  def platform
    @wechat_ticket = WechatTicket.new
    r = Hash.from_xml(request.body.read)['xml']
    @wechat_ticket.appid = r['AppId'] || params[:appid]
    @wechat_ticket.ticket_data = r['Encrypt']
    puts "$$$$$$$$$$$$$$$$$$$$#{r}"

    if @wechat_ticket.save
      render plain: 'success'
    else
      head :no_content
    end
  end

  private
  def set_wechat_app
    @wechat_app = WechatApp.valid.find(params[:id])
  end

  def set_wechat_agent
    @wechat_app = WechatApp.find params[:appid]
  end

  def verify_signature
    if @wechat_app
      msg_encrypt = nil
      #msg_encrypt = params[:echostr] || request_encrypt_content if @wechat_app.encrypt_mode
      signature = params[:signature] || params[:msg_signature]

      forbidden = (signature != Wechat::Signature.hexdigest(@wechat_app.token, params[:timestamp], params[:nonce], msg_encrypt))
    else
      forbidden = true
    end

    render plain: 'Forbidden', status: 403 if forbidden
  end

end
