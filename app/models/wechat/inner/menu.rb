# frozen_string_literal: true

module Wechat
  module Inner::Menu
    extend ActiveSupport::Concern

    included do
      attribute :type, :string
      attribute :name, :string
      attribute :value, :string
      attribute :mp_appid, :string
      attribute :mp_pagepath, :string
    end

  end
end
