
require 'roo'

# todo: write test to allow to use the same taxon name in parent taxons (Example: Fashion > Children's Clothing > Kids and Sports and Outdoors > Kids)
namespace :import do  
  task filters: :environment do
    puts 'Importing Filters'
    ods = Roo::Spreadsheet.open('lib/taxons/filters.xlsx')
    # Iterate through each sheet
    ods.each_with_pagename do |name, sheet|
      p name, sheet.row(1) # print tab name and first row 
      headers = sheet.row(1) # get header row
      type = value = nil
      
      sheet.each_with_index do |row, idx|
        next if idx == 0 # skip header
        filter = Hash[[headers, row].transpose]
        if filter['type_name'].present?
          type = Spree::OptionType.find_or_create_by(name: filter['type_name'], presentation: filter['type_presentation'])
          p "#{type.id} #{type.name}"
        end
        if filter['value_name'].present?
          value = Spree::OptionValue.find_or_create_by(name: filter['value_name'], presentation: filter['value_presentation'], option_type: type)
          p "- #{value.id} #{value.name} type.id: #{value.option_type_id}"
        end
      end
    end
  end
  
  
  task taxons: :environment do
    puts 'Importing All Taxons to Categories Taxonomy'
    ods = Roo::Spreadsheet.open('lib/taxons/all.xlsx')
    # puts ods.sheets
    
    # Iterate through each sheet
    ods.each_with_pagename do |name, sheet|
      p name, sheet.row(1) # print tab name and first row 
      headers = sheet.row(1) # get header row
      taxon = subtaxon = subtaxon2 = nil
      taxonomy = Spree::Taxonomy.find_or_create_by(name: "Categories")
      if name == "Categories"
        taxon_first = taxonomy.taxons.first
      else
        taxon_first = Spree::Taxon.find_or_create_by(name: name, parent: taxonomy.taxons.first, taxonomy: taxonomy)
      end
      sheet.each_with_index do |row, idx|
        next if idx == 0 # skip header
        taxon_data = Hash[[headers, row].transpose]
        # taxon
        if taxon_data['taxon'].present?
          taxon = Spree::Taxon.find_or_create_by(name: taxon_data['taxon'].rstrip, parent: taxon_first, taxonomy: taxonomy)
          subtaxon = subtaxon2 = nil
          puts "#{idx} #{taxon_data['taxon']} id: #{taxon.id} parent: #{taxon_first.id} == #{taxon.parent_id}"
        end
        # subtaxon
        if taxon_data['subtaxon'].present?
          subtaxon = Spree::Taxon.find_or_create_by(name: taxon_data['subtaxon'].rstrip, parent: taxon, taxonomy: taxonomy)
          puts "#{idx} -#{taxon_data['subtaxon']} id: #{subtaxon.id} parent: #{taxon.id} == #{subtaxon.parent_id}"
        end
        # subtaxon2
        if taxon_data['subtaxon2'].present?
          subtaxon2 = Spree::Taxon.find_or_create_by(name: taxon_data['subtaxon2'].rstrip, parent: subtaxon, taxonomy: taxonomy)
          puts "#{idx} --#{taxon_data['subtaxon2']} id: #{subtaxon2.id} parent: #{subtaxon.id} == #{subtaxon2.parent_id}"
        end
      end
    end
  end
  
  task taxonomies: :environment do
    puts 'Importing Taxonomies'
    ods = Roo::Spreadsheet.open('lib/taxons/all.xlsx')
    # puts ods.sheets
    
    # Iterate through each sheet
    ods.each_with_pagename do |name, sheet|
      p name, sheet.row(1) # print tab name and first row 
      headers = sheet.row(1) # get header row
      taxon = subtaxon = subtaxon2 = nil
      taxonomy = Spree::Taxonomy.find_or_create_by(name: name)
      taxon_first = taxonomy.taxons.first
      sheet.each_with_index do |row, idx|
        next if idx == 0 # skip header
        taxon_data = Hash[[headers, row].transpose]
        # taxon
        if taxon_data['taxon'].present?
          taxon = Spree::Taxon.find_or_create_by(name: taxon_data['taxon'].rstrip, parent: taxon_first, taxonomy: taxonomy)
          subtaxon = subtaxon2 = nil
          puts "#{idx} #{taxon_data['taxon']} id: #{taxon.id} parent: #{taxon_first.id} == #{taxon.parent_id}"
        end
        # subtaxon
        if taxon_data['subtaxon'].present?
          subtaxon = Spree::Taxon.find_or_create_by(name: taxon_data['subtaxon'].rstrip, parent: taxon, taxonomy: taxonomy)
          puts "#{idx} -#{taxon_data['subtaxon']} id: #{subtaxon.id} parent: #{taxon.id} == #{subtaxon.parent_id}"
        end
        # subtaxon2
        if taxon_data['subtaxon2'].present?
          subtaxon2 = Spree::Taxon.find_or_create_by(name: taxon_data['subtaxon2'].rstrip, parent: subtaxon, taxonomy: taxonomy)
          puts "#{idx} --#{taxon_data['subtaxon2']} id: #{subtaxon2.id} parent: #{subtaxon.id} == #{subtaxon2.parent_id}"
        end
      end
    end
  end
  

  desc "import taxons from excel file"
  task menu_structure: :environment do
    puts 'Importing Taxons'
    data = Roo::Spreadsheet.open('lib/taxons/all.xlsx')
    headers = data.row(1) # get header row
    taxon = subtaxon = subtaxon2 = nil
    taxonomy = Spree::Taxonomy.find_or_create_by(name: 'Categories')
    taxon_first = taxonomy.taxons.first
    data.each_with_index do |row, idx|
      next if idx == 0 # skip header
      # create hash from headers and cells
      taxon_data = Hash[[headers, row].transpose]
      
      # taxon
      if taxon_data['taxon'].present?
        if Spree::Taxon.exists?(name: taxon_data['taxon'])
          taxon = Spree::Taxon.find_by(name: taxon_data['taxon'])
          # next
        else
          taxon = Spree::Taxon.create(name: taxon_data['taxon'])
        end
        taxon.update(parent: taxon_first, taxonomy: taxonomy)
        subtaxon = nil
        subtaxon2 = nil
        puts "#{idx} #{taxon_data['taxon']} id: #{taxon.id} parent: #{taxon_first.id} == #{taxon.parent_id}"
      end
      

      # subtaxon
      if taxon_data['subtaxon'].present?
        if Spree::Taxon.exists?(name: taxon_data['subtaxon'], parent: taxon)
          subtaxon = Spree::Taxon.find_by(name: taxon_data['subtaxon'], parent: taxon)
          # next
        else
          subtaxon = Spree::Taxon.create(name: taxon_data['subtaxon'])
        end
        subtaxon.update(parent: taxon, taxonomy: taxonomy)
        puts "#{idx} -#{taxon_data['subtaxon']} id: #{subtaxon.id} parent: #{taxon.id} == #{subtaxon.parent_id}"
      end

      # subtaxon2
      if taxon_data['subtaxon2'].present?
        if Spree::Taxon.exists?(name: taxon_data['subtaxon2'], parent: subtaxon)
          subtaxon2 = Spree::Taxon.find_by(name: taxon_data['subtaxon2'], parent: subtaxon)
          # next
        else
          subtaxon2 = Spree::Taxon.create(name: taxon_data['subtaxon2'])
        end
        subtaxon2.update(parent: subtaxon, taxonomy: taxonomy)
        puts "#{idx} --#{taxon_data['subtaxon2']} id: #{subtaxon2.id} parent: #{subtaxon.id} == #{subtaxon2.parent_id}"
      end

    end
  end
end
