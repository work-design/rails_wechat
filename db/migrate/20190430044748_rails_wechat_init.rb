class RailsWechatInit < ActiveRecord::Migration[6.0]
  def change
    
    create_table :wechat_configs do |t|
      t.string :name
      t.string :type
      t.boolean :enabled
      t.boolean :primary

      t.string :appid
      t.string :secret
      t.string :agentid

      # when encrypt_mode is true, encoding_aes_key must be specified
      t.boolean :encrypt_mode
      t.string :encoding_aes_key

      t.string :token
      
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
      t.string :name
      t.string :match_value
      t.integer :expire_seconds
      t.string :qrcode_ticket
      t.string :qrcode_url
      t.string :valid_response
      t.string :invalid_response
      t.time :start_at
      t.time :finish_at
      t.timestamps
    end
    
    create_table :response_items do |t|
      t.references :wechat_response
      t.references :wechat_feedback
      t.references :wechat_user
      t.datetime :respond_at
      t.date :respond_on
      t.string :respond_in
      t.integer :position
      t.timestamps
    end
    
    create_table :wechat_feedbacks do |t|
      t.references :wechat_config
      t.references :wechat_user
      t.text :body
      t.integer :position
      t.date :feedback_on
      t.string :kind
      t.string :month
      t.timestamps
    end
    
    create_table :extractors do |t|
      t.references :wechat_config
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
    
  end
end
