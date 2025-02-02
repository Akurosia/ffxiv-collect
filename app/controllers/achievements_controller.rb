class AchievementsController < ApplicationController
  include Collection
  before_action :verify_character!, only: :index
  before_action :check_achievements!, except: :show

  def index
    @types = AchievementType.all.order(:id).includes(:categories, :achievements)
    @achievement_ids = @character&.achievement_ids || []
  end

  def show
    @achievement = Achievement.find(params[:id])
  end

  def type
    @type = AchievementType.find(params[:id])
    @achievements = @type.achievements
    @categories = @type.categories.includes(achievements: :title)
    @achievement_ids = @character&.achievement_ids || []
    @achievement_dates = @character&.character_achievements&.pluck(:achievement_id, :created_at).to_h || {}
  end
end
