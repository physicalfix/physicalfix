require "#{RAILS_ROOT}/config/environment.rb"
namespace :data do 
  
  task :index_foods do
    cr = "\r"
    clear = "\e[0K"
    reset = cr + clear
    count = 0
    
    
    length = Food.count
    puts "Indexing #{length} Foods"
    Food.all.each do |f|
      Sunspot.index(f)
      Sunspot.commit
    
      count = count + 1
      done = (((count.to_f/length.to_f) * 100)).floor
      print "#{reset}Progress: #{done}%  (#{count} / #{length})"
      $stdout.flush
    end
    
  end
  
  task :activites do
    require "#{RAILS_ROOT}/data/activites.rb"
    ACTIVITIES.each do |name, cbpppm|
      Activity.create(
        :name => name,
        :calories_burned_per_pound_per_minute => cbpppm
      )
    end
  end
  
  task :import do
    cr = "\r"
    clear = "\e[0K"
    reset = cr + clear

    count = 0
    puts "Importing food descriptions"
    food_file = File.open('data/FOOD_DES.txt').read
    food_file.gsub!('~','')
    rows = food_file.split("\n")
    length = rows.size
    rows.each do |row|
      cols = row.split('^')
      food = Food.new
      food.id = cols[0]
      food.food_group_id = cols[1]
      food.long_desc = cols[2]
      food.short_desc = cols[3]
      food.common_name = cols[4] unless cols[4] == ''
      food.manufac_name = cols[5] unless cols[5] == ''
      food.survey = cols[6] unless cols[6] == ''
      food.ref_desc = cols[7] unless cols[7] == ''
      food.refuse = cols[8] unless cols[8] == ''
      food.scientific_name = cols[9] unless cols[9] == ''
      food.n_factor = cols[10] unless cols[10] == ''
      food.pro_factor = cols[11] unless cols[11] == ''
      food.fat_factor = cols[12] unless cols[12] == ''
      food.cho_factor = cols[13] unless cols[13] == ''
      food.save
      count = count + 1
      done = (((count.to_f/length.to_f) * 100)).floor
      print "#{reset}Progress: #{done}%  (#{count} / #{length})"
      $stdout.flush
    end
    print "#{reset}"
    $stdout.flush
    puts "done"

    puts "Importing food groups"
    count = 0
    group_file = File.open('data/FD_GROUP.txt').read
    group_file.gsub!('~','')
    rows = group_file.split("\n")
    length = rows.size
    rows.each do |row|
      cols = row.split('^')
      group = FoodGroup.new
      group.id = cols[0]
      group.desc = cols[1]
      group.save
      count = count + 1
      done = (((count.to_f/length.to_f) * 100)).floor
      print "#{reset}Progress: #{done}%  (#{count} / #{length})"
      $stdout.flush
    end
    print "#{reset}"
    $stdout.flush
    puts "done"

    puts "Importing nutrient definitons"
    count = 0
    nutrient_file = File.open('data/NUTR_DEF.txt').read
    nutrient_file.gsub!('~','')
    rows = nutrient_file.split("\n")
    length = rows.size
    rows.each do |row|
      cols = row.split('^')
      nutrient = Nutrient.new
      nutrient.id = cols[0]
      nutrient.units = cols[1]
      nutrient.tagname = cols[2] unless cols[2] == ''
      nutrient.desc = cols[3]
      nutrient.num_dec = cols[4]
      nutrient.sr_order = cols[5]
      nutrient.save
      count = count + 1
      done = (((count.to_f/length.to_f) * 100)).floor
      print "#{reset}Progress: #{done}%  (#{count} / #{length})"
      $stdout.flush
    end
    print "#{reset}"
    $stdout.flush
    puts "done"

    puts "Importing nutrient data"
    count = 0
    nutrient_data = File.open('data/NUT_DATA.txt').read
    nutrient_data.gsub!('~', '')
    rows = nutrient_data.split("\n")
    length = rows.size
    rows.each do |row|
      cols = row.split('^')
      fn = FoodsNutrients.new
      fn.food_id = cols[0]
      fn.nutrient_id = cols[1]
      fn.value = cols[2]
      fn.data_points = cols[3] unless cols[3] == ''
      fn.std_error = cols[4] unless cols[4] == ''
      fn.source_id = cols[5]
      fn.derivation_id = cols[6] unless cols[6] == ''
      fn.ref_food_id = cols[7] unless cols[7] == ''
      fn.add_nutr_mark = cols[8] unless cols[8] == ''
      fn.num_studies = cols[9] unless cols[9] == ''
      fn.min = cols[10] unless cols[10] == ''
      fn.max = cols[11] unless cols[11] == ''
      fn.dof = cols[12] unless cols[12] == ''
      fn.low_eb = cols[13] unless cols[13] == ''
      fn.up_eb = cols[14] unless cols[14] == ''
      fn.stat_cmt = cols[15] unless cols[15] == ''
      fn.confidence = cols[16] unless cols[16] == ''
      fn.save
      count = count + 1
      done = (((count.to_f/length.to_f) * 100)).floor
      print "#{reset}Progress: #{done}%  (#{count} / #{length})"
      $stdout.flush
    end
    print "#{reset}"
    $stdout.flush
    puts "done"

    puts "Importing weights"
    count = 0
    weight_file = File.open('data/WEIGHT.txt').read
    weight_file.gsub!('~','')
    rows = weight_file.split("\n")
    length = rows.size
    rows.each do |row|
      cols = row.split('^')
      weight = Weight.new
      weight.food_id = cols[0]
      weight.sequence_number = cols[1]
      weight.amount = cols[2]
      weight.desc = cols[3]
      weight.gram_weight = cols[4]
      weight.data_points = cols[5] unless cols[5] == ''
      weight.std_dev = cols[6] unless cols[6] == ''
      weight.save
      count = count + 1
      done = (((count.to_f/length.to_f) * 100)).floor
      print "#{reset}Progress: #{done}%  (#{count} / #{length})"
      $stdout.flush
    end
    print "#{reset}"
    $stdout.flush
    puts "done"

    puts "Importing footnotes"
    count = 0
    footnote_file = File.open('data/FOOTNOTE.txt').read
    footnote_file.gsub!('~','')
    rows = footnote_file.split("\n")
    length = rows.size
    rows.each do |row|
      cols = row.split('^')
      footnote = Footnote.new
      footnote.food_id = cols[0]
      footnote.sequence_number = cols[1]
      footnote.footnote_type = cols[2]
      footnote.nutrient_id = cols[3] unless cols[3] == ''
      footnote.footnote_text = cols[4]
      footnote.save
      count = count + 1
      done = (((count.to_f/length.to_f) * 100)).floor
      print "#{reset}Progress: #{done}%  (#{count} / #{length})"
      $stdout.flush
    end
    print "#{reset}"
    $stdout.flush
    puts "done"

  end
end
    