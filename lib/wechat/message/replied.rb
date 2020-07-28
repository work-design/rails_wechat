# frozen_string_literal: true

class Wechat::Message::Replied < Wechat::Message::Base

  def initialize(request, **params)
    @request = request
    @message_hash = params.with_indifferent_access
  end

 

end
