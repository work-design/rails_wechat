# frozen_string_literal: true

class FileReplyUploadJob < ApplicationJob

  def perform(file_reply)
    file_reply.upload_file
  end

end
