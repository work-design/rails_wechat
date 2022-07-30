require "application_system_test_case"

class TemplateKeyWordsTest < ApplicationSystemTestCase
  setup do
    @wechat_panel_template_key_word = wechat_panel_template_key_words(:one)
  end

  test "visiting the index" do
    visit wechat_panel_template_key_words_url
    assert_selector "h1", text: "Template key words"
  end

  test "should create template key word" do
    visit wechat_panel_template_key_words_url
    click_on "New template key word"

    fill_in "Color", with: @wechat_panel_template_key_word.color
    fill_in "Example", with: @wechat_panel_template_key_word.example
    fill_in "Kid", with: @wechat_panel_template_key_word.kid
    fill_in "Mapping", with: @wechat_panel_template_key_word.mapping
    fill_in "Name", with: @wechat_panel_template_key_word.name
    fill_in "Rule", with: @wechat_panel_template_key_word.rule
    click_on "Create Template key word"

    assert_text "Template key word was successfully created"
    click_on "Back"
  end

  test "should update Template key word" do
    visit wechat_panel_template_key_word_url(@wechat_panel_template_key_word)
    click_on "Edit this template key word", match: :first

    fill_in "Color", with: @wechat_panel_template_key_word.color
    fill_in "Example", with: @wechat_panel_template_key_word.example
    fill_in "Kid", with: @wechat_panel_template_key_word.kid
    fill_in "Mapping", with: @wechat_panel_template_key_word.mapping
    fill_in "Name", with: @wechat_panel_template_key_word.name
    fill_in "Rule", with: @wechat_panel_template_key_word.rule
    click_on "Update Template key word"

    assert_text "Template key word was successfully updated"
    click_on "Back"
  end

  test "should destroy Template key word" do
    visit wechat_panel_template_key_word_url(@wechat_panel_template_key_word)
    click_on "Destroy this template key word", match: :first

    assert_text "Template key word was successfully destroyed"
  end
end
