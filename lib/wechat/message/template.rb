class Wechat::Message::Template < Wechat::Message::Base
  TEMPLATE_KEYS = [
    'template_id',
    'form_id',
    'page',
    'color',
    'emphasis_keyword',
    'topcolor',
    'url',
    'miniprogram',
    'data'
  ].freeze

  attr_reader :template
  def initialize(template, msg = {})
    super(app)

    @template = template
  end

  def do_send

  end


end
