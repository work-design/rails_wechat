module RailsWechat::TemplateConfig
  extend ActiveSupport::Concern

  included do
    attribute :type, :string
    attribute :title, :string
    attribute :tid, :string
    attribute :description, :string
    attribute :notifiable_type, :string
    attribute :code, :string, default: 'default'

    validates :code, uniqueness: { scope: :notifiable_type }

    has_many :template_key_words, -> { order(position: :asc) }, inverse_of: :template_config, dependent: :delete_all
    accepts_nested_attributes_for :template_key_words

    after_create_commit :sync_key_words
  end

  def kid_list
    template_key_words.where.not(mapping: [nil, '']).pluck(:kid)
  end

  def data_hash
    {}
  end

  def content
    template_key_words.where.not(mapping: [nil, '']).pluck(:name)
  end

  def sync_key_words
  end

  def notify_setting
    r = RailsNotice.notifiable_types.dig(notifiable_type, self.code.to_sym) || {}
    r.fetch(:only, []).map(&->(o){ [notifiable_type.constantize.human_attribute_name(o), o] }).to_h
  end

end
