## 用户相关功能
# 用户标签管理：https://developers.weixin.qq.com/doc/offiaccount/User_Management/User_Tag_Management.html

module Wechat::Api
  module Public::User
    BASE = 'https://api.weixin.qq.com/cgi-bin/'

    # https://developers.weixin.qq.com/doc/offiaccount/User_Management/User_Tag_Management.html
    def tags
      get 'tags/get', origin: BASE
    end

    def tag_create(tag_name, tag_id = nil)
      if tag_id.present?
        r = post 'tags/update', tag: { id: tag_id, name: tag_name }, origin: BASE
      else
        r = post 'tags/create', tag: { name: tag_name }, origin: BASE
      end

      if r['errcode'] == 0
        { 'tag' => { 'id' => tag_id, 'name' => tag_name } }
      elsif r['errcode'] == 45157
        { 'tag' => tags['tags'].find { |i| i['name'] == tag_name } }
      else
        r
      end
    end

    def tag_delete(tagid)
      post 'tags/delete', tag: { id: tagid }, origin: BASE
    end

    def tag_add_user(tagid, *openids)
      post 'tags/members/batchtagging', openid_list: openids, tagid: tagid, origin: BASE
    end

    def tag_del_user(tagid, *openids)
      post 'tags/members/batchuntagging', openid_list: openids, tagid: tagid, origin: BASE
    end

    def tag(tagid, next_openid = '')
      post 'user/tag/get', tagid: tagid, next_openid: next_openid, origin: BASE
    end

    def users(nextid = nil)
      params = {}
      params.merge! next_openid: nextid if nextid.present?

      get 'user/get', params: params, origin: BASE
    end

    def user(openid)
      get 'user/info', params: { openid: openid }, origin: BASE
    end

    def user_batchget(openids, lang = 'zh-CN')
      post 'user/info/batchget', user_list: openids.collect { |v| { openid: v, lang: lang } }, origin: BASE
    end

    def user_group(openid)
      post 'groups/getid', openid: openid, origin: BASE
    end

    def user_change_group(openid, to_groupid)
      post 'groups/members/update', openid: openid, to_groupid: to_groupid, origin: BASE
    end

    def user_update_remark(openid, remark)
      post 'user/info/updateremark', openid: openid, remark: remark, origin: BASE
    end

  end
end
