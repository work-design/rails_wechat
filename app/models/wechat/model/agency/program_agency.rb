# frozen_string_literal: true

module Wechat
  module Model::Agency::ProgramAgency

    def disabled_func_infos
      return unless platform.program_agency
      platform.program_agency.func_infos - func_infos
    end

  end
end
