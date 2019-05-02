Rails.application.routes.draw do

  scope module: :wechat do
    resources :wechats, only: [:show, :update] do
      post '' => :create, on: :member
    end
  end

  scope :my, module: 'wechat/my', as: :my do
  end

  scope :panel, module: 'wechat/panel', as: 'panel' do
    resource :wechat_config, excetp: [:new, :create]
  end

  scope :admin, module: 'wechat/admin', as: :admin do
    resources :wechat_configs do
      resources :wechat_menus
    end
  end

end
