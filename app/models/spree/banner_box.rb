module Spree
  class BannerBox < ActiveRecord::Base
    has_attached_file :attachment,
                url: '/spree/banners/:id/:style/:basename.:extension',
                default_url: '/spree/banners/:id/:style/:basename.:extension',
                path: ':rails_root/public/spree/banners/:id/:style/:basename.:extension',
                styles: { mini: '48x48>', small: '100x100>', banner: '200x200>' },
                default_style: :banner,
                convert_options: { :all => '-strip -auto-orient' }
    # save the w,h of the original image (from which others can be calculated)
    # we need to look at the write-queue for images which have not been saved yet
    after_post_process :find_dimensions

    validates_presence_of :category
    validates_attachment_presence :attachment
    validates_attachment_content_type :attachment, :content_type => ['image/jpeg', 'image/png', 'image/gif', 'image/jpg', 'image/x-png', 'image/pjpeg'], :message => I18n.t(:images_only)

    scope :enabled, lambda { |*categories|
      if categories.empty?
        where(:enabled => true)
      else
        where(:enabled => true).where(:category => categories)
      end
    }


    def initialize(*args)
      super(*args)
      last_banner = BannerBox.last
      self.position = last_banner ? last_banner.position + 1 : 0
    end

    # for adding banner_boxes which are closely related to existing ones
    # define "duplicate_extra" for site-specific actions, eg for additional fields
    def duplicate
      p = self.dup
      p.category = 'COPY OF ' + category
      p.created_at = p.updated_at = nil
      p.url = url
      p.attachment = attachment

      # allow site to do some customization
      p.send(:duplicate_extra, self) if p.respond_to?(:duplicate_extra)
      p.save!
      p
    end

    def find_dimensions
      temporary = attachment.queued_for_write[:original]
      filename = temporary.path unless temporary.nil?
      filename = attachment.path if filename.blank?
      geometry = Paperclip::Geometry.from_file(filename)
      self.attachment_width = geometry.width
      self.attachment_height = geometry.height
    end

    def self.categories_for_select
      unscoped.pluck(:category).uniq.sort
    end
  end
end
