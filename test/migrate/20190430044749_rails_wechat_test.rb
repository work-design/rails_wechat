class RailsWechatTest < ActiveRecord::Migration[6.0]
 
  def change
    create_table :oauth_users do |t|
      t.references :user
      t.references :account
      t.string :provider
      t.string :type
      t.string :uid
      t.string :unionid, index: true
      t.string :name
      t.string :avatar_url
      t.string :state
      t.string :access_token
      t.string :refresh_token
      t.string :app_id
      t.datetime :expires_at
      if connection.adapter_name == 'PostgreSQL'
        t.jsonb :extra
      else
        t.json :extra
      end
      t.index [:uid, :provider], unique: true
      t.timestamps
    end

    create_table :accounts do |t|
      t.references :user
      t.string :type
      t.string :identity
      t.boolean :confirmed, default: false
      t.boolean :primary, default: false
      t.timestamps
    end

    create_table :authorized_tokens do |t|
      t.references :user
      t.references :oauth_user
      t.references :account
      t.string :token
      t.datetime :expire_at
      t.string :session_key
      t.integer :access_counter, default: 0
      t.index [:user_id, :oauth_user_id, :account_id, :token], unique: true, name: 'index_authorized_tokens_on_unique_token'
      t.timestamps
    end

  end
  
end
