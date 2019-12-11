module Wechat::Api::Base::Datacube

  def getusersummary(begin_date, end_date)
    post 'getusersummary', begin_date: begin_date, end_date: end_date, base: DATACUBE_BASE
  end

  def getusercumulate(begin_date, end_date)
    post 'getusercumulate', begin_date: begin_date, end_date: end_date, base: DATACUBE_BASE
  end
  
end
