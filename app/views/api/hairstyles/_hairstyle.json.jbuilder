json.(hairstyle, :id, :name, :description, :patch, :item_id)
json.owned owned.fetch(hairstyle.id.to_s, '0%')
json.icon image_url("hairstyles/#{hairstyle.id}.png", skip_pipeline: true)
json.partial! 'api/shared/sources', collectable: hairstyle
