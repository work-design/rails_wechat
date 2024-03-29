module Wechat
  module Model::Reply::ImageReply
    extend ActiveSupport::Concern

    included do
      after_create_commit :upload_file_later
    end

    def msg_type
      'image'
    end

    def content
      {
        MsgType: 'image',
        Image: { MediaId: value }
      }
    end

    def upload_file_later
      FileReplyUploadJob.perform_later(self)
    end

    def upload_file
      Tempfile.open do |file|
        file.binmode

        HTTPX.get(media.url).body.each do |fragment|
          file.write fragment
        end

        file.rewind
        form_file = HTTP::FormData::File.new file.path, content_type: media.blob.content_type, filename: media.blob.filename
        r = app.api.material_add('image', form_file)
        if r['media_id']
          self.update value: r['media_id']
        else
          logger.info r
        end
      end
    end

  end
end
