
require 'roo'
require 'write_xlsx'

# todo: write test to allow to use the same taxon name in parent taxons (Example: Fashion > Children's Clothing > Kids and Sports and Outdoors > Kids)
namespace :timetrack do  
  task group_by_tag: :environment do
    all_total = 0
    puts 'Grouping by tag'
    [
      Roo::Spreadsheet.open('lib/tasks/timetracker/grouped_tag_by_day/Neobox.csv'),
      Roo::Spreadsheet.open('lib/tasks/timetracker/grouped_tag_by_day/Imensity.csv'),
    ].each do |ods|
      # Iterate through each sheet
      total = 0
      ods.each_with_pagename do |name, sheet|
        p name, sheet.row(1) # print tab name and first row 
        headers = sheet.row(1) # get header row
        items = {}
        category_name = ''
        sheet.each_with_index do |row, idx|
          # Date	Tag	Category	 	 	Hours	Formatted Time	Earned
          filter = Hash[[headers, row].transpose]
          next if idx == 0 # skip header
          category_name = filter['Category']
          if items[filter['Tag']].present?
            items[filter['Tag']] += filter['Hours'].to_f
            ## items[filter['Tag']][:'Hours'] += filter['Hours'].to_f
            # p "#{filter['Tag']} #{filter['Hours']} total: #{items[filter['Tag']]}"
          else
            items[filter['Tag']] = filter['Hours'].to_f
            # p "#{filter['Tag']} #{filter['Hours']} total: #{items[filter['Tag']]}"
          end
          total += filter['Hours'].to_f
          all_total += filter['Hours'].to_f
        end
        p "#{category_name} items: \n\n"
        items.each do |item|
          # p "#{item.first}, #{item.second}"
          p "'#{item.first}',#{item.second}"
        end
        
        FILE_PATH = "lib/tasks/timetracker/grouped_by_tag/#{category_name.downcase}.xlsx"
        workbook = WriteXLSX.new(FILE_PATH)
        worksheet = workbook.add_worksheet
        format = workbook.add_format # Add a format
        col = row = 0
        worksheet.write(0, col, category_name, format)
        row += 1
        items.each_with_index do |item, idx|
          worksheet.write(idx, col, item.first, format)
          worksheet.write(idx, col+1, item.second, format)
          row = idx
        end
        worksheet.write(row, col, 'total:', format)
        worksheet.write(row, col+1, total, format)
        workbook.close

        p "total (h): #{total}"
      end
    end
    p "Totally (h): #{all_total}"
  end
  
end
