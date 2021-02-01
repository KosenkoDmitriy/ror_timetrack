
require 'yaml'

namespace :export do
  task mega_menu: :environment do
    # p "Creating mega menu items (Categories, Women, Men, Children, Fashion, Start selling) with submenu items and banners"
    p "Creating mega menu items (Categories, Fashion, Electronics, Home Decor, Start selling) with submenu items and banners"
    spree_storefront = { default: { navigation: [] } }

    promo_banners = [
      { subtitle: 'New collection', title: 'Summer 2021', url: '#', image: 'meganav/promo_banner_left-first-category.jpg' },
      { subtitle: 'Special Offers', title: 'Get up to 30% off', url: '#', image: 'meganav/promo_banner_right-first-category.jpg' }
    ]
    
    # Categories mega menu item with 19 subtaxons
    Spree::Taxonomy.all.each do |taxonomy|
      items = []
      if taxonomy.taxons.count > 0
        cur_index = 0
        taxonomy.taxons.where('parent_id > 0').order(created_at: :asc).each do |taxon|
          if taxon.level <= 1 
            cur_index += 1
            if cur_index <= 19
              items << { title: taxon.name, url: "/t/#{taxon.permalink}" } 
            end
          end
        end
        spree_storefront[:default][:navigation] << { title: taxonomy.name, subtitle: taxonomy.name, url: "/t/#{taxonomy.taxons.first.permalink}", items: items, promo_banners: promo_banners }
      end
    end

    [
      { name: 'Fashion', name_taxon: 'Fashion' },
      { name: 'Electronics', name_taxon: 'Consumer Electronics ' },
      { name: 'Home Decor', name_taxon: 'Home, Interior & Furniture' }
    ].each do |item|
      taxon = Spree::Taxon.find_by(name: item[:name_taxon])
      if taxon.present? && taxon.level < 2
        items = []
        if taxon.children.count > 0
          taxon.children.order(created_at: :asc).each do |subtaxon|
            items << { title: subtaxon.name, url: "/t/#{subtaxon.permalink}" } 
          end          
        end

        spree_storefront[:default][:navigation] << { title: item[:name], subtitle: item[:name] || taxon.parent.name, url: "/t/#{taxon.permalink}", items: items, promo_banners: promo_banners }
      end
    end
    
    spree_storefront[:default][:navigation] << { title: 'Selling', subtitle: 'Categories', url: '/vendors/new' }
    
    puts spree_storefront
    file_name = 'spree_storefront_from_db.yml'
    File.open("config/#{file_name}", 'w+') do |file|
      file.write(spree_storefront.to_yaml)
    end

    if File.exist?("config/#{file_name}")
      SpreeStorefrontConfig = YAML.load_file(Rails.root.join('config', file_name)).with_indifferent_access
    end
  end
  
  task spree_storefront: :environment do
    puts "create 'categories' mega menu item with 19 taxons in the submenu (create spree_storefront.yml from database)"
    spree_storefront = { default: 
      { navigation: [
        # { title: 'Start Selling', subtitle: 'Categories', url: '/vendors/new' },
      ]}
    }

    promo_banners = []
    promo_banners << { subtitle: 'New collection', title: 'Summer 2021', url: '#', image: 'meganav/promo_banner_left-first-category.jpg' }
    promo_banners << { subtitle: 'Special Offers', title: 'Get up to 30% off', url: '#', image: 'meganav/promo_banner_right-first-category.jpg' }
    # promo_banners << { subtitle: 'Old collection', title: 'Summer 2020', url: '#', image: 'meganav/promo_banner_left-third-category.jpg' }
    # promo_banners << { subtitle: 'Special Offers', title: 'Get up to 40% off', url: '#', image: 'meganav/promo_banner_right-third-category.jpg' }
    
    Spree::Taxonomy.all.each do |taxonomy|
      items = []
      if taxonomy.taxons.count > 0
        cur_index = 0
        taxonomy.taxons.where('parent_id > 0').order(created_at: :asc).each do |taxon|
          if taxon.level <= 1 
            cur_index += 1
            if cur_index <= 19
              items << { title: taxon.name, url: "/t/#{taxon.permalink}" } 
            end
          end
        end
        spree_storefront[:default][:navigation] << { title: taxonomy.name, subtitle: taxonomy.name, url: "/t/#{taxonomy.taxons.first.permalink}", items: items, promo_banners: promo_banners }
      end
      # display all taxons with depth 1 as main nav menu items
      # if taxonomy.taxons.count > 0
      #   taxonomy.taxons.where('parent_id > 0').order(created_at: :asc).each do |taxon|
      #     if taxon.children.any? && taxon.level <= 1
      #       spree_storefront[:default][:navigation] << {title: taxon.name, subtitle: taxonomy.name, url: "/t/#{taxon.permalink}", items: taxon.children.map{ |taxon| {title: taxon.name, url: "/t/#{taxon.permalink}"} } }
      #     elsif taxon.level <= 1
      #       spree_storefront[:default][:navigation] << {title: taxon.name, subtitle: taxonomy.name, url: "/t/#{taxon.permalink}" }
      #     end
      #   end
      # end
    end
    spree_storefront[:default][:navigation] << { title: 'Start Selling', subtitle: 'Categories', url: '/vendors/new' }

    
    puts spree_storefront
    file_name = 'spree_storefront_from_db.yml'
    File.open("config/#{file_name}", 'w+') do |file|
      file.write(spree_storefront.to_yaml)
    end

    if File.exist?("config/#{file_name}")
      SpreeStorefrontConfig = YAML.load_file(Rails.root.join('config', file_name)).with_indifferent_access
    end

  end
end
