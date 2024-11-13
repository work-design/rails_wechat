module Wechat
  module Ext::Member
    extend ActiveSupport::Concern
    include Ext::Handle

    included do
      attribute :corp_userid, :string
      attribute :wechat_openid, :string

      belongs_to :member_inviter, class_name: 'Org::Member', optional: true
      belongs_to :wechat_user, class_name: 'Wechat::WechatUser', foreign_key: :wechat_openid, primary_key: :uid, optional: true

      has_many :corp_users, ->(o) { where(organ_id: o.organ_id) }, class_name: 'Wechat::CorpUser', primary_key: :corp_userid, foreign_key: :userid
      has_many :wechat_users, class_name: 'Wechat::WechatUser', through: :account, source: :oauth_users
      has_many :program_users, class_name: 'Wechat::ProgramUser', through: :account, source: :oauth_users
      has_many :medias, class_name: 'Wechat::Media'
      has_many :subscribes, -> { where(sending_at: nil).order(id: :asc) }, class_name: 'Wechat::Subscribe', through: :program_users
      has_many :scenes, as: :handle, class_name: 'Wechat::Scene'

      scope :wechat, -> { where.not(wechat_openid: [nil, '']) }
      scope :corp, -> { where.not(corp_userid: [nil, '']) }

      before_save :sync_from_wechat_user, if: -> { wechat_openid.present? && wechat_openid_changed? }
    end

    def invite_member!
      app = organ.provider&.app

      if app
        scene = scenes.find_or_initialize_by(appid: app.appid, organ_id: organ_id, aim: 'invite_member')
        scene.check_refresh
        scene.save
        scene
      end
    end

    def invite_contact!(app, tag_name)
      scene = scenes.find_or_initialize_by(appid: app.appid, organ_id: organ_id, aim: 'invite_contact', tag_name: tag_name)
      scene.check_refresh
      scene.save
      scene
    end

    def sync_from_wechat_user
      self.identity = identity.presence || wechat_user.identity
    end

  end
end
