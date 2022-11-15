# RailsWechat

[![测试](https://github.com/work-design/rails_wechat/actions/workflows/test.yml/badge.svg)](https://github.com/work-design/rails_wechat/actions/workflows/test.yml)
[![Docker构建](https://github.com/work-design/rails_wechat/actions/workflows/cd.yml/badge.svg)](https://github.com/work-design/rails_wechat/actions/workflows/cd.yml)
[![Gem](https://github.com/work-design/rails_wechat/actions/workflows/gempush.yml/badge.svg)](https://github.com/work-design/rails_wechat/actions/workflows/gempush.yml)

微信公众平台及微信开放平台一揽子集成方案。

## 特性
* 对微信生态所涉及的功能支持最全：
  * 微信公众号
  * 微信小程序
  * 微信开放平台
  * 企业微信
  * 企业微信服务商
  * 微信支付
  * 微信支付服务商
* 为 SaaS 而生，支持多账号：
  * 支持微信公众号多账号；
  * 支持微信支付多账号；
  * 微信第三方平台多账号；
  * Oauth2 授权多账号，就算是未经过认证的个人微信号，通过自动推送链接绑定账号依然可以实现 oauth2 登陆的效果； 
* 所有数据均自动存储至数据库；
* 全程在线 UI 配置，即时生效；
* 注释清晰，添加对文档的引用；

## 功能
* 精准消息推送，推送消息给你想推送的人群；
* 灵活强大的在线自动回复配置系统；
  * config 配置, 参见[示例](lib/rails_wechat/config.rb)；
  * 数据库配置；
* 可对用户在微信公众号的留言做自动解析；

## 使用

* 直接调用 api，示例：
```ruby
# 或 app = Wechat::App.find params[:id]
app = Wechat::App.take
app.api.msg_sec_check('test data')
```

## 许可证
遵循 [MIT](LICENSE) 协议
