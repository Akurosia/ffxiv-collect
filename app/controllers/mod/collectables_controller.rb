class Mod::CollectablesController < ModController
  before_action :set_model
  before_action :set_collectable, only: [:edit, :update]
  before_action :set_changes, only: [:edit, :update]

  def index
    @q = @model.all.ransack(params[:q])
    @collectables = @q.result.order(patch: :desc, id: :desc).paginate(page: params[:page])
    @collectables = @collectables.includes(sources: [:type, :related]) unless @skip_sources
  end

  def edit
    build_sources
  end

  def update
    update_params = collectable_params

    unless @skip_sources
      update_params[:sources_attributes].reject! { |_, source| source[:type_id].blank? }
      update_params[:sources_attributes].each do |key, source|
        type = SourceType.find(source[:type_id])
        case type.name
        when /(Achievement|Quest)/
          related = type.name.constantize.find_by(name_en: source[:text])
          update_params[:sources_attributes][key].merge!(related_id: related&.id, related_type: type.name)
        when /(Dungeon|Trial|Raid)/
          related = Instance.find_by(name_en: source[:text])
          update_params[:sources_attributes][key].merge!(related_id: related&.id, related_type: 'Instance')
        end
      end
    end

    if @collectable.update(update_params)
      flash[:success] = "The #{@model.to_s.downcase} has been updated."
      redirect_to polymorphic_url([:mod, @collectable], action: :edit)
    else
      flash[:error] = "There was a problem updating the #{@model.to_s.downcase}."
      build_sources
      render :edit
    end
  end

  private
  def set_model
    @model = controller_name.singularize.capitalize.constantize
  end

  def set_collectable
    @collectable = @model.find(params[:id])
  end

  def set_changes
    @changes = PaperTrail::Version.where(collectable_type: @model.to_s, collectable_id: @collectable.id)
      .or(PaperTrail::Version.where(item_type: @model.to_s, item_id: @collectable.id)).order(id: :desc)
  end

  def skip_sources
    @skip_sources = true
  end

  def build_sources
    2.times { @collectable.sources.build } unless @skip_sources
  end

  def collectable_params
    params.require(@model.to_s.downcase).permit(:name_en, :patch, sources_attributes:
                                                [:id, :type_id, :collectable_id, :collectable_type, :text])
  end
end
