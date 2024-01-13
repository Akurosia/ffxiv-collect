namespace 'sources:shops' do
  desc 'Create shop sources'
  task update: :environment do
    PaperTrail.enabled = false

    include ActionView::Helpers::NumberHelper

    fate_type = SourceType.find_by(name_en: 'FATE')
    gold_saucer_type = SourceType.find_by(name_en: 'Gold Saucer')
    hunts_type = SourceType.find_by(name_en: 'Hunts')
    purchase_type = SourceType.find_by(name_en: 'Purchase')
    pvp_type = SourceType.find_by(name_en: 'PvP')
    wondrous_tails_type = SourceType.find_by(name_en: 'Wondrous Tails')

    puts 'Creating GilShop sources'
    item_ids = XIVData.sheet('GilShopItem', raw: true).map do |entry|
      entry['Item']
    end

    Item.where.not(unlock_id: nil).where.not(price: 0).where(id: item_ids).each do |item|
      unlock = item.unlock
      text = "#{number_with_delimiter(item.price)} Gil"
      create_shop_source(unlock, purchase_type, text)
    end

    puts 'Creating SpecialShop sources'
    item_ids = Item.where.not(unlock_id: nil).pluck(:id).map(&:to_s)

    XIVData.sheet('SpecialShop', raw: true).each do |shop|
      2.times do |j|
        60.times do |i|
          item_id = shop["Item{Receive}[#{i}][#{j}]"]
          break if item_id == '0'
          next unless item_ids.include?(item_id)

          price = shop["Count{Cost}[#{i}][#{j}]"]
          next if price == '0'

          currency = shop["Item{Cost}[#{i}][#{j}]"]
          case currency.to_i
          when 25
            type = pvp_type
          when 27, 10307, 26533
            type = hunts_type
          when 29
            type = gold_saucer_type
          when 26807
            type = fate_type
          when 30341
            type = wondrous_tails_type
          else
            type = purchase_type
          end

          unlock = Item.find(item_id).unlock
          currency = Item.find(shop["Item{Cost}[#{i}][#{j}]"])
          text = "#{number_with_delimiter(price)} #{price == '1' ? currency.name_en : currency.plural_en}"

          # Do not create shop sources for Moogle Treasure Trove rewards
          unless text.match?('Irregular Tomestones')
            create_shop_source(unlock, type, text)
          end
        end
      end
    end

    puts 'Creating Grand Company sources'
    XIVData.sheet('GCScripShopItem', raw: true).each do |entry|
      next unless item_ids.include?(entry['Item'])

      unlock = Item.find(entry['Item']).unlock
      price = entry['Cost{GCSeals}']
      text = "#{number_with_delimiter(price)} Company Seals"
      create_shop_source(unlock, purchase_type, text)
    end
  end
end

private
# Create shop sources for collectables with no known sources.
# In the event of Orchestrion rolls, set the details.
def create_shop_source(unlock, type, text)
  unless unlock.sources.any?
    unlock.sources.create!(type: type, text: text)
  end
end
