module Wechat
  module Model::Corp
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :corp_id, :string, index: true
      attribute :corp_type, :string
      attribute :subject_type, :string
      attribute :verified_end_at, :datetime
      attribute :square_logo_url, :string
      attribute :user_max, :integer
      attribute :full_name, :string
      attribute :wxqrcode, :string
      attribute :industry, :string
      attribute :sub_industry, :string
      attribute :auth_corp_info, :json
      attribute :auth_user_info, :json
      attribute :register_code_info, :json
      attribute :agent, :json

      belongs_to :organ, class_name: 'Org::Organ'
    end


  end
end
