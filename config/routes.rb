Rails.application.routes.draw do

  scope module: :wechat do
    resources :wechats, only: [:show, :update] do
      post '' => :create, on: :member
    end
  end

  scope :my, module: 'wechat/my', as: :my do
  end

  scope :panel, module: 'wechat/panel', as: 'panel' do
    resources :wechat_configs
  end

  scope :admin, module: 'wechat/admin', as: :admin do
    resources :wechat_configs do
      resources :wechat_menus do
        post :sync, on: :collection
      end
      resources :wechat_responses
      resources :wechat_feedbacks, except: [:new, :create]
    end
  end

end
