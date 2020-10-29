Rails.application.routes.draw do

  scope module: :wechat, defaults: { business: 'wechat' } do
    resources :wechats, only: [:show] do
      member do
        post '' => :create
      end
    end
    resources :wechat_program_users do
      collection do
        post :mobile
        post :info
      end
    end
    resources :wechat_apps, only: [:show] do

    end
    controller :wechat do
      post 'wechat/auth' => :auth
      post :wx_notice
    end
    resources :wechat_platforms, only: [:show] do
      member do
        get :callback
      end
      collection do
        post ':appid/callback' => :message
      end
    end
  end

  scope :my, module: 'wechat/my', as: :my, defaults: { namespace: 'my', business: 'wechat' } do
    resource :user, only: [] do
      collection do
        get :invite_qrcode
      end
    end
    resources :wechat_subscribeds
    resources :wechat_registers do
      member do
        get 'code' => :edit_code
      end
    end
  end

  scope :panel, module: 'wechat/panel', as: :panel, defaults: { namespace: 'panel', business: 'wechat' } do
    resources :template_configs
    resources :wechat_platforms do
      resources :wechat_agencies, shallow: true, as: :agencies
    end
  end

  scope :admin, module: 'wechat/admin', as: :admin, defaults: { namespace: 'admin', business: 'wechat' } do
    resources :wechat_registers do
      member do
        get 'app' => :edit_app
        get 'bind' => :edit_bind
        patch 'bind' => :update_bind
        get 'qrcode' => :edit_qrcode
        get 'assign' => :edit_assign
        patch 'assign' => :update_assign
        put :qrcode
        put :code
      end
    end
    resources :wechat_apps do
      collection do
        get :own
      end
      member do
        get :info
      end
      resources :wechat_responses do
        member do
          post :sync
          get 'reply' => :edit_reply
          patch 'reply' => :update_reply
        end
      end
      resources :wechat_requests, except: [:new, :create]
      resources :wechat_replies do
        member do
          get 'news' => :edit_news
        end
      end
      resources :wechat_tags do
        collection do
          post :sync
        end
      end
      resources :wechat_users
      resources :wechat_templates do
        collection do
          get :default
          post :sync
        end
        resources :wechat_notices
      end
    end
    resources :wechat_responses, only: [] do
      resources :wechat_extractors
    end
    resources :wechat_menus do
      collection do
        get :default
        get :new_parent
        post :sync
      end
      member do
        get :edit_parent
      end
    end
    resources :accounts, only: [] do
      member do
        get :qrcode
      end
    end
  end

end
