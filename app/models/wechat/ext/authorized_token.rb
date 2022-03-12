module Wechat
  module Ext::AuthorizedToken
    extend ActiveSupport::Concern

    included do
      belongs_to :corp_user
    end

  end
end
