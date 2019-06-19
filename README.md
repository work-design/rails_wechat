# RailsWechat

微信公众平台及微信开放平台集大成者。

## 特性
* 为 SaaS 而生，支持多账号；
* 可配置自动回复；
* 可对用户在微信公众号的留言做自动解析；
* 早期引用了 [wechat](https://github.com/Eric-Guo/wechat) gem, 发现并不能很好满足需求，于是进行了重写：
  * 只考虑 Rails 或 Rails Engine 使用场景，于是移除了大量代码；
  * 解决了 wechat 存在的顽疾：添加账号后需要重启，不支持多公众号同时缓存access_token；
  * 经过重写，代码量减少了 1/2 以上, 代码逻辑更清晰，性能更佳，功能更完善； 
* 对公众号极低的要求，就算是未经过认证的个人微信号，依然可以实现 oauth2 登陆的效果； 

如果你只是在Rails里使用微信公众号功能，强烈建议直接使用本 gem，并配合经过我改造后的 [omniauth-wechat-oauth2](https://github.com/qinmingyuan/omniauth-wechat-oauth2) 使用。



## License
The gem is available as open source under the terms of the [LGPL-3.0](https://opensource.org/licenses/LGPL-3.0).
