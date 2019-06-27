class RailsWechatInit < ActiveRecord::Migration[6.0]
  def change
    
    create_table :wechat_configs do |t|
      t.string :name
      t.string :type
      t.boolean :enabled
      t.boolean :primary

      t.string :appid
      t.string :secret
      t.string :token

      t.string :agentid  # 企业微信所用
      t.string :mch_id  # 支付专用、商户号
      t.string :key  # 支付专用

      # when encrypt_mode is true, encoding_aes_key must be specified
      t.boolean :encrypt_mode
      t.string :encoding_aes_key
      
      t.string :access_token
      t.datetime :access_token_expires_at
      t.string :jsapi_ticket
      t.datetime :jsapi_ticket_expires_at
      t.string :help, limit: 1024
      t.timestamps
    end
    
    create_table :wechat_menus do |t|
      t.references :wechat_config
      t.references :parent
      t.string :type
      t.string :menu_type
      t.string :name
      t.string :value
      t.string :appid
      t.string :pagepath
      t.integer :position
      t.timestamps
    end

    create_table :wechat_responses do |t|
      t.references :wechat_config
      t.references :effective, polymorphic: true
      t.string :type
      t.string :match_value
      t.integer :expire_seconds
      t.string :qrcode_ticket
      t.string :qrcode_url
      t.timestamps
    end

    create_table :wechat_requests do |t|
      t.references :wechat_config
      t.references :wechat_user
      t.string :type
      t.text :body
      t.timestamps
    end
    
    create_table :tickets do |t|
      t.references :organ_id  # For SaaS
      t.integer :serial_start
      t.time :start_at
      t.time :finish_at
      t.string :valid_response
      t.string :invalid_response
      t.timestamps
    end
    
    create_table :ticket_items do |t|
      t.references :ticket
      t.references :wechat_request
      t.references :wechat_user
      t.integer :serial_number
      t.timestamps
    end
    
    create_table :extractors do |t|
      t.references :organ  # for SaaS
      t.string :name
      t.string :prefix
      t.string :suffix
      t.boolean :more
      t.timestamps
    end
    
    create_table :extractions do |t|
      t.references :extractor
      t.references :extractable, polymorphic: true
      t.string :name
      t.string :matched
      t.timestamps
    end
    
    create_table :wechat_config_extractors do |t|
      t.references :extractor
      t.references :wechat_config
      t.timestamps
    end
    
  end
end
