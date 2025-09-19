class Wechat::ProgramApi
  module Custom
    BASE = 'https://api.weixin.qq.com/cgi-bin/customservice/'

    def work_bind(corpid, **options)
      post 'work/bind', corpid: corpid, **options, origin: BASE
    end

    def work_unbind(corpid, **options)
      post 'work/unbind', corpid: corpid, **options, origin: BASE
    end

    def work_get
      get 'work/get', origin: BASE
    end

  end
end

