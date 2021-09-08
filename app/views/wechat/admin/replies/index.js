import { Controller } from '@hotwired/stimulus'

class WechatReplyController extends Controller {
  static targets = [ 'output' ]

  connect() {
    console.debug(this.identifier, 'connected!')
  }

}

application.register('wechat-reply', WechatReplyController)
