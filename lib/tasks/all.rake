require 'sprite_factory'
require 'xiv_data'

namespace :data do
  desc 'Initialize all data'
  task initialize: :environment do
    Rake::Task['sources:create_types'].invoke
    Rake::Task['data:update'].invoke
    Rake::Task['relics:create'].invoke
    Rake::Task['records:sources:create'].invoke
    Rake::Task['survey_records:solutions:set'].invoke

    # Triple Triad
    Rake::Task['triad:card_types:create'].invoke
    Rake::Task['triad:cards:create'].invoke
    Rake::Task['triad:packs:create'].invoke
  end

  desc 'Updates all data'
  task update: :environment do
    unless Dir.exist?(XIVData::IMAGE_PATH)
      puts "ERROR: Could not find image source directory: #{XIVData::IMAGE_PATH}"
      puts 'Images will not be generated.'
    end

    unless Dir.exist?(XIVData::MUSIC_PATH)
      puts "ERROR: Could not find music source directory: #{XIVData::MUSIC_PATH}"
      puts 'Music samples will not be generated.'
    end

    Rake::Task['items:create'].invoke
    Rake::Task['instances:create'].invoke
    Rake::Task['quests:create'].invoke
    Rake::Task['achievements:create'].invoke
    Rake::Task['titles:create'].invoke
    Rake::Task['mounts:create'].invoke
    Rake::Task['minions:create'].invoke
    Rake::Task['orchestrions:create'].invoke
    Rake::Task['emotes:create'].invoke
    Rake::Task['bardings:create'].invoke
    Rake::Task['hairstyles:create'].invoke
    Rake::Task['armoires:create'].invoke
    Rake::Task['spells:create'].invoke
    Rake::Task['fashions:create'].invoke
    Rake::Task['facewear:create'].invoke
    Rake::Task['records:create'].invoke
    Rake::Task['survey_records:create'].invoke
    Rake::Task['frames:create'].invoke
    Rake::Task['triad:card_types:create'].invoke
    Rake::Task['triad:cards:create'].invoke

    # Sources
    Rake::Task['items:set_unlocks'].invoke
    Rake::Task['items:set_extras'].invoke
    Rake::Task['sources:update'].invoke

    # Triple Triad
    Rake::Task['triad:rules:create'].invoke
    Rake::Task['triad:npcs:create'].invoke
    Rake::Task['triad:card_images:create'].invoke

    # Events
    Rake::Task['tomestones:latest:create'].invoke
    Rake::Task['tomestones:images:create'].invoke
  end
end

def log(message)
  puts "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S %Z')}] #{message}"
end

# Replace various tags with the appropriate text
def sanitize_text(text, preserve_space: false)
  text = text.gsub('<SoftHyphen/>', "\u00AD")
    .gsub(/<Switch.*?><Case\(1\)>(.*?)<\/Case>.*?<\/Switch>/m, '\1')
    .gsub(/<If.*?>(.*?)<Else\/>.*?<\/If>/m, '\1')
    .gsub(/<\/?Emphasis>/, '*')
    .gsub(/<UIForeground>.*?<\/UIGlow>(.*?)<UIGlow>.*?<\/UIForeground>/, '**\1**')
    .gsub(/<Highlight>(.*?)<\/Highlight>/, '**\1**')
    .gsub(/<Split\((.*?),.*?>/, '\1')
    .gsub('<Indent/>', ' ')
    .gsub('ObjectParameter(1)', 'Player')
    .gsub(/<.*?>(.*?)<\/.*?>/, '')

  unless preserve_space
    text = text.gsub("\r", "\n").gsub("\n", ' ')
  end

  text.strip
end

def sanitize_skill_description(text)
  text.gsub('<SoftHyphen/>', "\u00AD")
    .gsub(/<UIForeground>.*?<\/UIGlow>(.*?)<UIGlow>.*?<\/UIForeground>/, '**\1**')
    .gsub('<Indent/>', ' ')
    .gsub(/<.*?>(.*?)<\/.*?>/, '')
    .strip
end

# Titleize names and translate various tags
def sanitize_name(name)
  name = name.split(' ').each { |s| s[0] = s[0].upcase }.join(' ')
  name.gsub('[t]', 'der')
    .gsub('[a]', 'e')
    .gsub('[A]', 'er')
    .gsub('[p]', '')
    .gsub(/\uE0BE ?/, '')
    .gsub('<SoftHyphen/>', "\u00AD")
    .gsub('<Indent/>', ' ')
    .gsub(/\<.*?\>/, '')
    .gsub(/\((.)/) { |match| match.upcase } # (extreme) → (Extreme)
end

def without_custom(data)
  data.symbolize_keys.except(:name_en, :name_fr, :name_de, :name_ja, :patch)
end

def updated?(model, data)
  data.symbolize_keys!
  current = model.attributes.symbolize_keys.select { |k, _| data.keys.include?(k) }

  # The XIVData values are all strings, so convert integers to strings for comparison
  current.each do |k, v|
    current[k] = v.to_s if v.is_a?(Integer)
  end

  if updated = data != current
    puts "  Found new data for #{model.name_en} (#{model.id}):"
    diff = data.map do |k, v|
      "#{k}: #{current[k]} → #{v}" if current[k] != v
    end
    puts "    #{diff.compact.join(', ')}"
  end

  updated
end

def maps_with_locations(ids)
  # Look up the maps for the given IDs and set the coordinate data
  maps = XIVData.sheet('Map', raw: true).each_with_object({}) do |map, h|
    if ids.include?(map['#'])
      h[map['#']] = { region_id: map['PlaceName{Region}'], location_id: map['PlaceName'],
                      x_offset: map['Offset{X}'].to_f, y_offset: map['Offset{Y}'].to_f,
                      size_factor: map['SizeFactor'].to_f }
    end
  end

  # Look up the locations associated with each map
  locations = %w(en fr de ja).each_with_object(Hash.new({})) do |locale, h|
    places = XIVData.sheet('PlaceName', locale: locale, drop_zero: false).map { |place| place['Name']}
    maps.values.each do |map|
      h[map[:location_id]] = h[map[:location_id]].merge("name_#{locale}" => places[map[:location_id].to_i],
                                                        "region_#{locale}" => places[map[:region_id].to_i])
    end
  end

  # Create the locations
  locations.each do |id, data|
    Location.find_or_create_by!(data.merge(id: id))
  end

  maps
end

def get_coordinate(value, map_offset, size_factor)
  scale = size_factor / 100.0
  offset = (value + map_offset) * scale
  (((41.0 / scale) * ((offset + 1024.0) / 2048.0)) + 1).round(1)
end

def link_music(path)
  return unless Dir.exist?(XIVData::MUSIC_PATH)

  FileUtils.ln_s(path, Rails.root.join('public/music', path.sub(/.*\//, '')), force: true)
end

def create_image(id, icon_path, path, mask_from = nil, mask_to = nil, width = nil, height = nil)
  return unless Dir.exist?(XIVData::IMAGE_PATH)

  # Use the custom output pathname if provided, otherwise generate it
  if path.class == Pathname
    output_path = path
  else
    output_path = Rails.root.join('public/images', path, "#{id}.png")
  end

  unless output_path.exist?
    image_path = XIVData.image_path(icon_path)

    begin
      if mask_from.present?
        mask_to ||= mask_from
        image = ChunkyPNG::Image.from_file(image_path)
        image.change_theme_color!(ChunkyPNG::Color.from_hex(mask_from), ChunkyPNG::Color.from_hex(mask_to),
                                  ChunkyPNG::Color::TRANSPARENT)
      elsif width.present?
        image = ChunkyPNG::Image.from_file(image_path)
        image.resample_bilinear!(width, height)
      else
        image = URI.open(image_path).read
      end

      URI.open(output_path.to_s, 'wb') { |file| file << image }
    rescue StandardError
      puts "Could not create image: #{output_path}"
    end
  end
end

def create_spritesheet(path)
  output_image = path.gsub('/', '-')
  class_name = output_image.singularize
  options = { style: :scss, layout: :packed, library: :chunkypng,
              nocomments: true, output_image: Rails.root.join('app/assets/images', "#{output_image}.png"),
              output_style: Rails.root.join('app/assets/stylesheets/images', "#{output_image}.scss") }

  SpriteFactory.run!(Rails.root.join('public/images', path), options) do |images|
    rules = []
    image = images.values.first

    rules << "img.#{class_name} { width: #{image[:width]}px; height: #{image[:height]}px; " \
      "background: url(image_path('#{output_image}.png')) no-repeat }"

    images.each do |_, img|
      rules << "img.#{class_name}-#{img[:name]} { background-position: #{-img[:cssx]}px #{-img[:cssy]}px }"
    end

    rules.join("\n")
  end
end

def create_hair_spritesheets
  Hairstyle.all.each do |hairstyle|
    images = Dir.glob(Rails.root.join('public/images/hairstyles', hairstyle.id.to_s, '*.png')).sort
    sheet = ChunkyPNG::Image.new(192 * images.size, 192)

    images.each_with_index do |image, i|
      sheet.compose!(ChunkyPNG::Image.from_file(image), 192 * i, 0)
    end

    sheet.save(Rails.root.join('app/assets/images/hairstyles', "#{hairstyle.id}.png").to_s)
  end
end

def create_facewear_spritesheets
  Facewear.all.each do |facewear|
    images = Dir.glob(Rails.root.join('public/images/facewear', facewear.id.to_s, '*.png')).sort
    sheet = ChunkyPNG::Image.new(80 * images.size, 80)

    images.each_with_index do |image, i|
      sheet.compose!(ChunkyPNG::Image.from_file(image), 80 * i, 0)
    end

    sheet.save(Rails.root.join('app/assets/images/facewear', "#{facewear.id}.png").to_s)
  end
end
