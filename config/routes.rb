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
    resources :wechat_apps, only: [:show]
    controller :wechat do
      post 'wechat/auth' => :auth
    end
    resources :wechat_platforms, only: [:show] do
      member do
        get :callback
        post 'callback/:appid' => :message
      end
      collection do
        post :notice
      end
    end
  end

  scope :my, module: 'wechat/my', as: :my, defaults: { business: 'wechat', namespace: 'my' } do
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

  scope 'wechat/panel', module: 'wechat/panel', as: :panel, defaults: { business: 'wechat', namespace: 'panel' } do
    resources :template_configs
    resources :apps
    resources :wechat_platforms do
      resources :agencies, shallow: true, as: :agencies
    end
  end

  scope 'wechat/share', module: 'wechat/share', defaults: { business: 'wechat', namespace: 'share' } do
    resources :apps do
      resources :scenes do
        member do
          patch :sync
        end
        resources :wechat_users do
          member do
            patch :try_match
          end
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
      end
    end
  end

  scope 'wechat/admin', module: 'wechat/admin', as: :admin, defaults: { business: 'wechat', namespace: 'admin' } do
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
    resources :apps do
      member do
        get :info
        get 'cert' => :edit_cert
        patch 'cert' => :update_cert
      end
      resources :responses do
        member do
          post :sync
          get 'reply' => :edit_reply
          patch 'reply' => :update_reply
        end
      end
      resources :requests, except: [:new, :create]
      resources :wechat_replies do
        member do
          get 'news' => :edit_news
        end
      end
      resources :tags do
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
    resources :responses, only: [] do
      resources :extractors
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
