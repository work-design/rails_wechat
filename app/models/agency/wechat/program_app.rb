module Wechat
  class ProgramApp < Agency
    include Model::Agency::ProgramApp
    include Inner::ProgramApp
  end
end
