module MenusHelper
    def menu_options(start_item = nil)
      options = []
      menu_items = start_item ? start_item.children : Menu.top_level
      menu_items.map do |menu_item|
        options << [menu_item.padded_name, menu_item.id]
        if menu_item.children.size > 0         
         options += menu_options(menu_item) 
        end
      end
      options
    end
end
