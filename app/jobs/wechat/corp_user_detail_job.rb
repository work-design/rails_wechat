# frozen_string_literal: true

module Wechat
  class CorpUserDetailJob < ApplicationJob

    def perform(model)
      model.get_detail
    end

  end
end
