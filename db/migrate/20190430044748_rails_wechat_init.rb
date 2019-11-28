class RailsWechatInit < ActiveRecord::Migration[6.0]
  def change
    
    create_table :wechat_apps do |t|
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
      t.string :help_without_user
      t.string :help_feedback
      t.timestamps
    end
    
    create_table :wechat_messages do |t|
      t.references :wechat_app
      t.references :messaging, polymorphic: true
      t.string :type
      t.string :value
      if connection.adapter_name == 'PostgreSQL'
        t.jsonb :body
      else
        t.json :body
      end
      t.timestamps
    end
    
    create_table :wechat_message_tags do |t|
      t.references :wechat_message
      t.references :wechat_tag
      t.timestamps
    end
    
  end
end
