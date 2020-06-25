json.(character, :id, :name, :server, :portrait, :avatar, :last_parsed)
json.verified character.verified?

json.achievements do
  json.count character.achievements_count == -1 ? 0 : character.achievements_count
  json.total Achievement.count
  json.points character.achievement_points
  json.points_total Achievement.sum(:points)
  json.public character.achievements_count != -1
  if params[:ids].present?
    json.ids character.achievement_ids
  end
end

%w(mount minion orchestrion emote barding hairstyle armoire spell).each do |collectable|
  json.set! collectable.pluralize do
    json.count character.send("#{collectable}s_count")
    json.total collectable == 'minion' ? Minion.summonable.count : collectable.capitalize.constantize.count
    if params[:ids].present?
      json.ids character.send("#{collectable}_ids")
    end
  end
end

if @triad.present? && @triad[:status] == :ok
  json.triad do
    json.count @triad[:status] == :ok ? @triad[:cards][:owned] : 0
    json.total @triad[:status] == :ok ? @triad[:cards][:total] : 0
  end
end
