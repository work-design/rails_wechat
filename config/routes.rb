Rails.application.routes.draw do
  scope RailsCom.default_routes_scope do
    namespace :wechat, defaults: { business: 'wechat' } do
      controller :wechat do
        post :auth
        post :js
        post :agent_js
        get :login
        get :friend
      end
      scope path: 'qy_wechat', controller: :qy_wechat do
        get :login
      end
      resources :program_users do
        collection do
          post :mobile
          post :info
        end
      end
      resources :apps, only: [:show] do
        member do
          get :login
          post '' => :create
          patch :qrcode
        end
      end
      resources :agents, only: [:show] do
        member do
          get :login
          post '' => :create
        end
      end
      resources :agencies, only: [:show] do
        member do
          get :login
        end
      end
      resources :platforms, only: [:show] do
        member do
          get :callback
          post 'callback/:appid' => :message
          post :notify
        end
      end
      resources :providers, only: [:show] do
        member do
          get :auth
          post :callback
          post :notify
        end
      end
      resources :suites, only: [] do
        member do
          get :login
          get 'redirect/:corp_id' => :redirect
          get 'callback' => :verify
          get 'notify' => :verify
          post :callback
          post :notify
        end
      end
      resources :corps, only: [:show] do
        member do
          get :login
          post :notify
        end
      end
      resources :app_configs, only: [:index]

      namespace :me, defaults: { namespace: 'me' } do
        resource :corp_users
        resources :externals
      end

      namespace :my, defaults: { namespace: 'my' } do
        resource :user, only: [] do
          collection do
            get :invite_qrcode
            get :gift
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
        root 'home#index'
        resources :template_configs do
          member do
            get :apps
            post :sync
          end
          resources :template_key_words
        end
        resources :registers do
          member do
            get 'app' => :edit_app
            get 'assign' => :edit_assign
            patch 'assign' => :update_assign
            get 'bind' => :edit_bind
            patch 'bind' => :updaet_bind
            get :qrcode
            get :code
          end
        end
        resources :apps do
          member do
            get :key
          end
        end
        resources :corp_external_users, only: [:index, :show, :edit, :update, :destroy]
        resources :menu_roots, only: [:new, :create, :edit, :update, :destroy] do
          resources :menus, only: [:new, :create]
        end
        resources :menus, except: [:new, :create] do
          collection do
            get :new_parent
          end
          member do
            get :edit_parent
          end
        end
        resources :platforms do
          member do
            get :agency
          end
          resources :agencies do
            collection do
              post :search
            end
          end
          resources :platform_templates do
            collection do
              post :sync
            end
          end
          resources :platform_tickets
          resources :platform_receives
        end
        resources :contacts
        resources :providers do
          resources :suites do
            resources :corps do
              resources :corp_users
              resources :maintains
            end
            resources :suite_receives
          end
        end
        resources :developers
        resources :partners do
          member do
            get 'cert' => :edit_cert
            patch 'cert' => :update_cert
          end
          resources :partner_payees
        end
      end

      namespace :in, defaults: { namespace: 'in' } do
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
            resources :app_menus do
              collection do
                get :default
                post :sync
              end
            end
          end
        end
      end

      namespace :board, defaults: { namespace: 'board' } do
        resources :organs
      end

      namespace :admin, defaults: { namespace: 'admin' } do
        root 'home#index'
        resource :organ, only: [:show, :edit, :update]
        resources :members, only: [:index, :show, :edit, :update]
        resources :menu_roots do
          resources :menus, only: [:new, :create]
        end
        resources :menus do
          member do
            get :edit_parent
          end
        end
        resources :payees do
          member do
            get 'cert' => :edit_cert
            patch 'cert' => :update_cert
          end
          resources :payee_domains
          resources :payee_apps do
            resources :receivers do
              collection do
                get :users
                get 'openid' => :new_openid
                delete 'openid/:uid' => :destroy_openid
              end
            end
          end
        end
        resources :agents do
          member do
            get :info
            get 'confirm' => :edit_confirm
            patch 'confirm' => :update_confirm
          end
          resources :suite_receives
          resources :corp_users do
            resources :follows do
              collection do
                post :sync
              end
            end
          end
        end
        resources :apps do
          member do
            get :info
          end
          resources :scenes do
            member do
              patch :sync
            end
          end
          resources :responses do
            member do
              post :sync
              get :filter_reply
              get 'reply' => :edit_reply
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
          resources :user_tags
          resources :templates do
            collection do
              get :default
              post :sync
            end
            resources :notices
          end
          resources :menu_apps do
            collection do
              post :sync
            end
          end
          resources :app_configs
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

  get '*path' => 'wechat/apps#confirm', format: false, constraints: ->(req) { req.path.to_s.end_with?('.txt') } if RailsWechat.config.confirm
end
