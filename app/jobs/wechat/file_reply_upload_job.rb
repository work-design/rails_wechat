# frozen_string_literal: true
module Wechat
  class FileReplyUploadJob < ApplicationJob

    def perform(file_reply)
      file_reply.upload_file
    end

  end
end
