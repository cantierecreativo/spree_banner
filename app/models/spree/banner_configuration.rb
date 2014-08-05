module Spree
  class BannerConfiguration < Preferences::Configuration
    preference :admin_sliders_per_page, :integer, default: 10
  end
end
