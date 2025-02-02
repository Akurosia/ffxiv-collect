namespace :patches do
	desc 'Sets initial patch data for various collectables'
	task set: :environment do
    puts 'Filling in initial patch data'
		Barding.where(name_en: ['Behemoth Barding', 'Black Mage Barding', 'Butlery Barding', 'Far Eastern Barding',
													'Gridanian Barding', 'Gridanian Crested Barding', 'Gridanian Half Barding', 'Lominsan Barding',
													'Lominsan Crested Barding', 'Lominsan Half Barding', 'Sleipnir Barding', "Ul'dahn Barding",
													"Ul'dahn Crested Barding", "Ul'dahn Half Barding", 'Lominsan Saddle', 'Gridanian Saddle',
													"Ul'dahn Saddle", 'Paladin Barding', 'Dragoon Barding', 'White Mage Barding']).update(patch: '2.0')

		Barding.find_by(name_en: 'Barding of Light').update(patch: '2.2')
		Barding.find_by(name_en: 'Tidal Barding').update(patch: '2.2')
		Barding.find_by(name_en: 'Levin Barding').update(patch: '2.3')
		Barding.find_by(name_en: 'Plumed Barding').update(patch: '2.3')
		Barding.find_by(name_en: 'Eerie Barding').update(patch: '2.38')
		Barding.find_by(name_en: 'Sovereign Barding').update(patch: '2.1')
		Barding.find_by(name_en: 'Starlight Barding').update(patch: '2.1')
		Barding.find_by(name_en: 'Shinryu Barding').update(patch: '4.1')
		Barding.find_by(name_en: 'Ixion Barding').update(patch: '4.1')
		Barding.find_by(name_en: 'Red Mage Barding').update(patch: '4.25')
		Barding.find_by(name_en: 'Race Barding').update(patch: '3.25')
		Barding.find_by(name_en: "Reveler's Barding").update(patch: '4.0')
		Barding.find_by(name_en: 'Ala Mhigan Barding').update(patch: '4.0')
		Barding.find_by(name_en: 'Blissful Barding').update(patch: '4.0')
		Barding.find_by(name_en: 'Hingan Barding').update(patch: '4.0')
		Barding.find_by(name_en: 'Oriental Barding').update(patch: '4.0')
		Barding.find_by(name_en: 'Nezha Barding').update(patch: '4.2')
		Barding.find_by(name_en: 'Byakko Barding').update(patch: '4.2')
		Barding.find_by(name_en: 'Paramour Barding').update(patch: '2.5')
		Barding.find_by(name_en: 'Gambler Barding').update(patch: '2.51')
		Barding.find_by(name_en: 'Ice Barding').update(patch: '2.4')
		Barding.find_by(name_en: 'Horde Barding').update(patch: '3.3')
		Barding.find_by(name_en: 'Sephirotic Barding').update(patch: '3.2')
		Barding.find_by(name_en: 'Egg Hunter Barding').update(patch: '3.2')
		Barding.find_by(name_en: 'Zurvanite Barding').update(patch: '3.5')
		Barding.find_by(name_en: 'Mandervillian Barding').update(patch: '3.4')
		Barding.find_by(name_en: 'Sophic Barding').update(patch: '3.4')
		Barding.find_by(name_en: 'Abigail Barding').update(patch: '3.4')
		Barding.find_by(name_en: 'Angelic Barding').update(patch: '3.5')
		Barding.find_by(name_en: 'Demonic Barding').update(patch: '3.5')
		Barding.find_by(name_en: 'Round Table Barding').update(patch: '3.1')
		Barding.find_by(name_en: 'Ishgardian Half Barding').update(patch: '3.0')
		Barding.find_by(name_en: 'Ishgardian Barding').update(patch: '3.0')
		Barding.find_by(name_en: 'Noble Barding').update(patch: '3.0')
		Barding.find_by(name_en: 'Highland Barding').update(patch: '3.0')
		Barding.find_by(name_en: 'Expanse Barding').update(patch: '3.0')
		Barding.find_by(name_en: 'Hive Barding').update(patch: '3.0')
		Barding.find_by(name_en: 'Wild Rose Barding').update(patch: '3.07')
		Barding.find_by(name_en: 'Orthodox Barding').update(patch: '3.0')
		Barding.find_by(name_en: 'Lunar Barding').update(patch: '4.3')
		Barding.find_by(name_en: 'Suzaku Barding').update(patch: '4.4')
		Barding.find_by(name_en: 'Samurai Barding').update(patch: '4.45')
		Barding.find_by(name_en: 'Seiryu Barding').update(patch: '4.45')
		Barding.find_by(name_en: 'Yojimbo Barding').update(patch: '4.5')
		Barding.find_by(name_en: 'Flyer Shaffron').update(patch: '3.0')
		Barding.find_by(name_en: 'Egg Barding').update(patch: '2.2')
		Barding.find_by(name_en: 'Chocobo Raincoat').update(patch: '4.2')
	end
end
