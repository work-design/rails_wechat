module RailsWechat::PublicTemplate
  extend ActiveSupport::Concern

  included do
    attribute :title, :string
    attribute :tid, :string
    attribute :description, :string
    attribute :notifiable_type, :string
    attribute :code, :string, default: 'default'

    validates :code, uniqueness: { scope: :notifiable_type }

    has_many :template_key_words, -> { order(position: :asc) }, dependent: :delete_all
    accepts_nested_attributes_for :template_key_words

    after_create_commit :sync_key_words
  end

  def kid_list
    template_key_words.where.not(mapping: [nil, '']).pluck(:kid)
  end

  def content
    template_key_words.where.not(mapping: [nil, '']).pluck(:name)
  end

  def sync_key_words
    app = WechatProgram.default
    return [] unless app
    key_words = app.api.template_key_words tid
    key_words.each do |kw|
      tkw = template_key_words.find_or_initialize_by(kid: kw['kid'])
      tkw.name = kw['name']
      tkw.example = kw['example']
      tkw.rule = kw['rule']
      tkw.save
    end
  end

  def notify_setting
    r = RailsNotice.notifiable_types.dig(notifiable_type, self.code.to_sym) || {}
    r.fetch(:only, []).map(&->(o){ [notifiable_type.constantize.human_attribute_name(o), o] }).to_h
  end

end
