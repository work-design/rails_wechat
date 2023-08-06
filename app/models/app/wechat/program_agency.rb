module Wechat
  class ProgramAgency < Agency
    include Model::App::ProgramAgency
    include Inner::ProgramApp
  end
end
