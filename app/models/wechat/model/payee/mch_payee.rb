module Wechat
  module Model::Payee::MchPayee
    extend ActiveSupport::Concern

    included do
      belongs_to :parter_payee, foreign_key: :mch_id, primary_key: :mch_id, optional: true
    end

  end
end
