module Wechat
  module Model::UserTag
    extend ActiveSupport::Concern

    included do
      has_many :tags, dependent: :destroy

      after_save_commit :sync_tag_later, if: -> { saved_change_to_name? }
    end

    def sync_tag_later
      WechatTagJob.perform_later(self)
    end

    def sync_tag
      _app = app
      return unless _app
      wt = tags.find_or_initialize_by(app_id: _app.id)
      wt.name = self.name
      wt.save
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

  end
end
