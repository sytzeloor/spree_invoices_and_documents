module Spree
  class Document < ActiveRecord::Base
    has_attached_file :document,
      url: Spree::Config.attachment_default_url.gsub('/products/', '/documents/'),
      path: Spree::Config.attachment_path.gsub('/products/', '/documents/')

    belongs_to :source, polymorphic: true

    validate :name, presence: true

    def upload_content?
      upload_content_type.to_s.match(/\/(pdf|doc|docx|xls|xlsx|odt|ods)/)
    end
  end
end
