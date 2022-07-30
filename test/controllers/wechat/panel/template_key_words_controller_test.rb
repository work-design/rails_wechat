require 'test_helper'
class Wechat::Panel::TemplateKeyWordsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @template_key_word = template_key_words(:one)
  end

  test 'index ok' do
    get url_for(controller: 'wechat/panel/template_key_words')

    assert_response :success
  end

  test 'new ok' do
    get url_for(controller: 'wechat/panel/template_key_words')

    assert_response :success
  end

  test 'create ok' do
    assert_difference('TemplateKeyWord.count') do
      post(
        url_for(controller: 'wechat/panel/template_key_words', action: 'create'),
        params: { template_key_word: { color: @wechat_panel_template_key_word.color, example: @wechat_panel_template_key_word.example, kid: @wechat_panel_template_key_word.kid, mapping: @wechat_panel_template_key_word.mapping, name: @wechat_panel_template_key_word.name, rule: @wechat_panel_template_key_word.rule } },
        as: :turbo_stream
      )
    end

    assert_response :success
  end

  test 'show ok' do
    get url_for(controller: 'wechat/panel/template_key_words', action: 'show', id: @template_key_word.id)

    assert_response :success
  end

  test 'edit ok' do
    get url_for(controller: 'wechat/panel/template_key_words', action: 'edit', id: @template_key_word.id)

    assert_response :success
  end

  test 'update ok' do
    patch(
      url_for(controller: 'wechat/panel/template_key_words', action: 'update', id: @template_key_word.id),
      params: { template_key_word: { color: @wechat_panel_template_key_word.color, example: @wechat_panel_template_key_word.example, kid: @wechat_panel_template_key_word.kid, mapping: @wechat_panel_template_key_word.mapping, name: @wechat_panel_template_key_word.name, rule: @wechat_panel_template_key_word.rule } },
      as: :turbo_stream
    )

    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('TemplateKeyWord.count', -1) do
      delete url_for(controller: 'wechat/panel/template_key_words', action: 'destroy', id: @template_key_word.id), as: :turbo_stream
    end

    assert_response :success
  end

end
