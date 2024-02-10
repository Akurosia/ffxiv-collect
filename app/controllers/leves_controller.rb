class LevesController < ApplicationController
  include ManualCollection

  before_action :display_verify_alert!, only: [:battlecraft, :tradecraft, :fieldcraft]
  before_action :set_prices!, only: [:tradecraft, :fieldcraft]

  def index
    @leves = Leve.include_related.where('leve_categories.craft_en = ?', @craft).with_filters(cookies).ordered
    @categories = LeveCategory.where(id: @leves.pluck(:category_id).uniq).ordered.to_a

    @category = params[:category].to_i
    @category = @categories.first.id unless @categories.pluck(:id).include?(@category)
    @categories.unshift(nil) # Workaround for category buttons expecting the first category to be "All"

    render :index
  end

  def battlecraft
    @craft = 'Battlecraft'
    index
  end

  def tradecraft
    @craft = 'Tradecraft'
    index
  end

  def fieldcraft
    @craft = 'Fieldcraft'
    index
  end

  def add
    add_collectable(@character.leves, Leve.find(params[:id]))
  end

  def remove
    remove_collectable(@character.leves, params[:id])
  end
end
