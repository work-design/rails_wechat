Rails.application.routes.draw do

  scope module: :wechat do
    resources :wechats, only: [:show, :update] do
      post '' => :create, on: :member
    end
    resources :wechat_program_users do
      collection do
        post :mobile
        post :info
      end
    end
  end

  scope :my, module: 'wechat/my', as: :my do
  end

  scope :admin, module: 'wechat/admin', as: 'admin' do
    resources :wechat_apps do
      get :own, on: :collection
      get 'help' => :edit_help, on: :member
      get :info, on: :member
      resources :wechat_responses do
        post :sync, on: :member
      end
      resources :wechat_requests, except: [:new, :create]
      resources :wechat_tags do
        post :sync, on: :collection
      end
      resources :wechat_users
    end
    resources :wechat_menus do
      collection do
        get :default
        get :new_parent
        post :sync
      end
      get :edit_parent, on: :member
    end
    resources :extractors
    resources :tickets
    resources :accounts, only: [] do
      get :qrcode, on: :member
    end
  end

end
