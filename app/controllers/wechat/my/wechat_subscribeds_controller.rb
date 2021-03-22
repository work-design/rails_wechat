module Wechat
  class My::SubscribedsController < My::BaseController

    def create
      r = wechat_subscribeds_params.to_h.map do |k, v|
        next if k.blank?
        template = current_wechat_user.app.templates.find_by template_id: k
        wechat_subscribed = current_wechat_user.wechat_subscribeds.build(status: v)
        wechat_subscribed.template = template
        wechat_subscribed.save
        wechat_subscribed
      end

      render json: r.as_json
    end

    private
    def wechat_subscribeds_params
      params.fetch(:wechat_subscribeds, {}).permit!
    end

  end
end
