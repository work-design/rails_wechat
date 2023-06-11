module Wechat
  class ProgramAgency < Agency
    include Model::Agency::ProgramAgency
    include Inner::ProgramApp
  end
end
