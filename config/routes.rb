Rails.application.routes.draw do

  scope module: :wechat do
    resources :wechats, only: [:show, :update] do
      post '' => :create, on: :member
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
      resources :wechat_tags
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
    resources :wechat_tag_defaults
  end

end
