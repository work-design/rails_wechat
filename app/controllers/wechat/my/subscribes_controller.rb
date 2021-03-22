module Wechat
  class My::SubscribesController < My::BaseController

    def create
      r = subscribes_params.to_h.map do |k, v|
        next if k.blank?
        template = current_wechat_user.app.templates.find_by template_id: k
        subscribe = current_wechat_user.subscribes.build(status: v)
        subscribe.template = template
        subscribe.save
        subscribe
      end

      render json: r.as_json
    end

  end
end
