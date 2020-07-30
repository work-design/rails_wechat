# RailsWechat

微信公众平台及微信开放平台集大成者。

## 特性
* 支持微信公众号，企业微信，微信小程序，微信开放平台；
* 为 SaaS 而生，支持多账号；
* 早期引用了 [wechat](https://github.com/Eric-Guo/wechat) gem, 发现并不能很好满足需求，于是进行了重写：
  * 只考虑 Rails 或 Rails Engine 使用场景，于是移除了大量代码；
  * 支持多公众号同时缓存access_token；
  * 经过重写，代码量减少了 1/2 以上, 代码逻辑更清晰，性能更佳，功能更完善； 
* 对公众号极低的要求，就算是未经过认证的个人微信号，依然可以实现 oauth2 登陆的效果； 
* 支持微信支付多账号配置；
* 注释清晰，添加对文档的引用；
* 支持多账号 omniauth 登陆；

如果你只是在Rails里使用微信公众号功能，强烈建议直接使用本 gem。

## 功能
* 精准消息推送，推送消息给你想推送的人群；
* 灵活强大的在线自动回复配置系统；
  * `on`语法配置；
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
