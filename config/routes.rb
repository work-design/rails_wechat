Rails.application.routes.draw do

  namespace :wechat, defaults: { business: 'wechat' } do
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
    resources :apps, only: [:show]
    controller :wechat do
      post 'wechat/auth' => :auth
    end
    resources :platforms, only: [:show] do
      member do
        get :callback
        post 'callback/:appid' => :message
      end
      collection do
        post :notice
      end
    end

    namespace :my, defaults: { namespace: 'my' } do
      resource :user, only: [] do
        collection do
          get :invite_qrcode
          get :requests
        end
      end
      resources :subscribeds
      resources :registers do
        member do
          get 'code' => :edit_code
        end
      end
      resources :medias
    end

    namespace :panel, defaults: { namespace: 'panel' } do
      resources :template_configs
      resources :apps
      resources :menus do
        collection do
          get :new_parent
        end
        member do
          get :edit_parent
        end
      end
      resources :platforms do
        resources :agencies, shallow: true, as: :agencies
      end
    end

    namespace :share, defaults: { namespace: 'share' } do
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
          resources :menus do
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

    namespace :admin, defaults: { namespace: 'admin' } do
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
            get :filter_reply
            patch 'reply' => :update_reply
          end
        end
        resources :requests, except: [:new, :create]
        resources :replies do
          collection do
            post :build
          end
          member do
            get :add
          end
          resources :news_reply_items, only: [:destroy]
        end
        resources :tags do
          collection do
            post :sync
          end
        end
        resources :wechat_users
        resources :templates do
          collection do
            get :default
            post :sync
          end
          resources :notices
        end
        resources :menus do
          collection do
            get :new_parent
            post :sync
          end
          member do
            get :edit_parent
          end
        end
      end
      resources :responses, only: [] do
        resources :extractors
      end
      resources :accounts, only: [] do
        member do
          get :qrcode
        end
      end
    end

  end

end
