class RelicsController < ApplicationController
  include ManualCollection
  before_action :display_verify_alert!, only: [:weapons, :tools, :armor, :garo]
  before_action :check_achievements!, only: [:weapons, :tools, :garo]
  before_action :set_relic_collection!, only: [:weapons, :tools, :armor, :garo]
  skip_before_action :set_owned!, :set_ids!, :set_dates!, :set_prices!

  def weapons
    @types = RelicType.where(category: 'weapons').where.not(jobs: 0).order(order: :desc)
  end

  def tools
    @types = RelicType.where(category: 'tools').order(order: :desc)
  end

  def armor
    @types = RelicType.where(category: 'armor').order(expansion: :desc, order: :desc)
    @categories = @types.pluck(:expansion).uniq.map do |expansion|
      OpenStruct.new(id: expansion, name: t("expansions.#{expansion}"))
    end
  end

  def garo
    @weapons = RelicType.find_by(name_en: 'GARO Weapons')
    @armor = RelicType.find_by(name_en: 'GARO Armor')
  end

  def add
    add_collectable(@character.relics, Relic.find(params[:id]))
  end

  def remove
    remove_collectable(@character.relics, params[:id])
  end

  private
  def set_relic_collection!
    @collection_ids = @character&.relic_ids || []
    @achievement_ids = @character&.achievement_ids || []
    @owned = Redis.current.hgetall('relics')
    @dates = @character&.character_relics&.pluck('relic_id', :created_at).to_h || {}
    @achievements = Achievement.where(id: Relic.all.pluck(:achievement_id).compact).pluck(:id, :name_en).to_h # TODO: remove this
  end
end
