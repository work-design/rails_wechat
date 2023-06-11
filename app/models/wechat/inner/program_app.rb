# frozen_string_literal: true

module Wechat
  module Inner::ProgramApp
    extend ActiveSupport::Concern

    included do
      attribute :confirm_name, :string
      attribute :confirm_content, :string
    end

    def get_webview_file!
      r = api.webview_domain_file
      self.confirm_name = r['file_name']
      self.confirm_content = r['file_content']
      self.save
    end

  end
end
