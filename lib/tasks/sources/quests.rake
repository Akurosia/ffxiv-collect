namespace 'sources:quests' do
  desc 'Create sources from quest rewards'
  task update: :environment do
    PaperTrail.enabled = false

    puts 'Creating Quest sources'

    # Create quest sources for items that have associated unlocks
    Item.includes(:quest).where.not(unlock_id: nil).where.not(quest_id: nil).each do |item|
      next if item.unlock.sources.any?

      create_quest_source(item, item.unlock)
    end

    # Create quest sources for outfits based on their associated items
    Outfit.includes(items: :quest).all.each do |outfit|
      next if outfit.sources.any?

      outfit.items.each do |item|
        if item.quest_id.present?
          create_quest_source(item, outfit)
          break
        end
      end
    end
  end

  def create_quest_source(item, collectable)
    quest = item.quest
    source_type = SourceType.find_by(name_en: quest.event ? 'Event' : 'Quest')

    collectable.sources.find_or_create_by!(text_en: quest.name_en, text_de: quest.name_de,
                                           text_fr: quest.name_fr, text_ja: quest.name_ja,
                                           type: source_type, limited: quest.event?,
                                           related_type: 'Quest', related_id: quest.id)
  end
end
