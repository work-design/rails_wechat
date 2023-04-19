# frozen_string_literal: true

module Wechat
  class CorpExternalUserJob < ApplicationJob

    def perform(model)
      model.get_external_userid!
    end

  end
end
