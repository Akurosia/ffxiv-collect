# == Schema Information
#
# Table name: npcs
#
#  id          :bigint(8)        not null, primary key
#  x           :decimal(3, 1)
#  y           :decimal(3, 1)
#  resident_id :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  quest_id    :integer
#  patch       :string(255)
#  name_en     :string(255)      not null
#  name_de     :string(255)      not null
#  name_fr     :string(255)      not null
#  name_ja     :string(255)      not null
#  location_id :integer          not null
#  difficulty  :decimal(3, 2)
#  excluded    :boolean          default(FALSE)
#

class NPC < ApplicationRecord
  include Collectable

  translates :name

  has_many :npc_cards
  has_many :npc_rewards
  has_many :cards, through: :npc_cards
  has_many :fixed_cards, -> { where('npc_cards.fixed = true') }, through: :npc_cards, source: :card
  has_many :variable_cards, -> { where('npc_cards.fixed = false') }, through: :npc_cards, source: :card
  has_many :rewards, through: :npc_rewards, source: :card
  has_many :decks
  has_and_belongs_to_many :rules, dependent: :delete_all
  belongs_to :location
  belongs_to :quest, optional: true

  after_save :touch_related

  scope :include_related, -> { include_sources.includes(:rules, :location, :quest, rewards: :type) }
  scope :ordered, -> { order(patch: :desc, id: :desc) }
  scope :valid, -> { where(excluded: false) }

  def self.available_filters
    %i(owned)
  end

  def self.defeated_npcs(character)
    # Find the NPCs with at least one card reward owned by the character that only has a single source.
    # This single NPC source would have been automatically created with the NPC.
    # Verify that each source is an NPC before adding it to the list.
    ids = Card.joins(npc_rewards: :npc)
      .joins(character_cards: :character)
      .where('characters.id = ?', character.id)
      .left_joins(:sources)
      .group('sources.collectable_id')
      .having('count(sources.id) = 1')
      .select('sources.related_type as related_type, sources.related_id as related_id')
      .filter_map { |card| card.related_id if card.related_type == 'NPC' }
      .uniq

    # Filter the existing defeated NPC IDs
    (ids - character.npc_ids).uniq
  end

  private
  def touch_related
    decks.touch_all
    rewards.touch_all
  end
end
