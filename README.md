# RailsWechat

微信公众平台及微信开放平台集大成者。

## 特性
* 支持微信公众号，企业微信，微信小程序，微信开放平台几乎所有已开放功能；
* 为 SaaS 而生，支持多账号：
  * 微信公众号多账号；
  * 微信支付多账号；
  * 微信第三方平台多账号；
  * Oauth2 授权多账号； 
* 对公众号极低的要求，就算是未经过认证的个人微信号，依然可以实现 oauth2 登陆的效果； 
* 注释清晰，添加对文档的引用；

## 功能
* 精准消息推送，推送消息给你想推送的人群；
* 灵活强大的在线自动回复配置系统；
  * config 配置, 参见[示例](lib/rails_wechat/config.rb)；
  * 数据库配置；
* 可对用户在微信公众号的留言做自动解析；

## 使用
* 仅支持UI数据库配置公众号；
* 调用api
```ruby
# 或 wechat_app = WechatApp.find params[:id]
wechat_app = WechatApp.default
wechat_app.api.msg_sec_check('test data')
```

## 许可证
许可证采用 [LGPL-3.0](https://opensource.org/licenses/LGPL-3.0)
