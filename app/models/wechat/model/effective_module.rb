module Wechat
  module Model::EffectiveModule

    def invoke_effect(wechat_user)
      p 'please implement in class'
    end

    def qrcode_later
      WechatQrcodeJob.perform_later(self)
    end

    def app
      if self.respond_to? :organ_id
        _organ_id = organ_id
      else
        _organ_id = nil
      end

      if App.column_names.include?('organ_id')
        App.find_by(organ_id: _organ_id, primary: true)
      else
        App.find_by(primary: true)
      end
    end

    def qrcode
      wa = app
      wa = backup_app if wa.nil?

      if response
        response.effective? ? response : response.refresh
      else
        create_response(type: 'TempScanResponse', app_id: wa.id) if wa
      end
    end

    def backup_app
      app_id = Rails.application.credentials.dig(:wechat, Rails.env.to_sym, :appid)
      WechatApp.find_by(appid: app_id)
    end

    def qrcode_url
      qrcode.qrcode_file_url
    end

  end
end
