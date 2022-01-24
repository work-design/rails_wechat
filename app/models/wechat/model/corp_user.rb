module Wechat
  module Model::CorpUser
    extend ActiveSupport::Concern

    included do
      attribute :corp_id, :string
      attribute :user_id, :string
      attribute :device_id, :string
      attribute :user_ticket, :string
      attribute :ticket_expires_at, :datetime
      attribute :open_userid, :string
      attribute :open_id, :string

      belongs_to :provider, optional: true
      belongs_to :corp, foreign_key: :corp_id, primary_key: :corp_id, optional: true
    end

    def xx

    end

    def auto_join_organ
      user_tags.each do |user_tag|
        next unless user_tag.tag_name.start_with?('invite_member_')
        member = members.find_by(organ_id: user_tag.member_inviter.organ_id) || members.build(organ_id: user_tag.member_inviter.organ_id, state: 'pending_trial')
        member.set_current_cart(user_tag.app.organ_id)
        member.save
      end
    end

  end
end
