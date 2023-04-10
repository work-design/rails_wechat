# frozen_string_literal: true

module Wechat
  module Model::Agency::PublicAgency

    def disabled_func_infos
      return unless platform.public_agency
      platform.public_agency.func_infos - func_infos
    end

  end
end
