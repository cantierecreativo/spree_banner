Deface::Override.new(:virtual_path => "spree/admin/shared/_menu",
                      :name => "banner_box_admin_tab",
                      :insert_bottom => "[data-hook='admin_tabs'], #admin_tabs[data-hook]",
                      :text => "<%= tab(:banner_boxes, :url => spree.admin_banner_boxes_path, :icon => 'bookmark') %>")
