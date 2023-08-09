# frozen_string_literal: true

module Wechat
  module Inner::ProgramApp
    extend ActiveSupport::Concern

    included do
      attribute :confirm_name, :string
      attribute :confirm_content, :string

      has_one_attached :qrcode

      after_create_commit :get_webview_file_later
    end

    def api
      return @api if defined? @api
      @api = Wechat::Api::Program.new(self)
    end

    def domain
      organ&.mp_host
    end

    def generate_wechat_user(code)
      info = api.jscode2session(code)
      logger.debug "\e[35m  Program Generate User: #{info}  \e[0m"

      program_user = ProgramUser.find_or_initialize_by(uid: info['openid'])
      program_user.appid = appid
      program_user.assign_attributes info.slice('unionid', 'session_key')
      program_user.init_user
      program_user
    end

    def get_qrcode
      file = api.get_qrcode
      self.qrcode.attach io: file, filename: "qrcode_#{id}"
    end

    def get_webview_file_later
      AgencyWebviewFileJob.perform_later(self)
    end

    def get_webview_file!
      r = api.webview_domain_file
      self.confirm_name = r['file_name']
      self.confirm_content = r['file_content']
      self.save
    end

    def update_open_appid!
      r = api.open_get
      if r['errcode'] == 0
        self.update open_appid: r['open_appid']
      end
    end

  end
end
