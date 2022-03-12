module Wechat
  module Ext::AuthorizedToken
    extend ActiveSupport::Concern

    included do
      belongs_to :corp_user, class_name: 'Wechat::CorpUser', optional: true
    end

  end
end
