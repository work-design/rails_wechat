module Wechat
  class Panel::PlatformTemplatesController < Panel::BaseController
    before_action :set_platform
    def index
      @platform_templates = @platform.platform_templates.order(template_id: :desc).page(params[:page])
    end

    def sync
      @platform.sync_templates
    end

    private
    def set_platform
      @platform = Platform.find params[:platform_id]
    end
  end
end
