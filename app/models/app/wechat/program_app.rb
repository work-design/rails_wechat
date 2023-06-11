module Wechat
  class ProgramApp < App
    include Model::App::ProgramApp
    include Inner::ProgramApp
  end
end
