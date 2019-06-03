/datum/map_template/ruin/lavaland
	prefix = "_maps/map_files/RandomRuins/LavaRuins/"

/datum/map_template/ruin/lavaland/biodome
	cost = 5
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/biodome/beach
	name = "Biodome Beach"
	id = "biodome-beach"
	description = "Seemingly plucked from a tropical destination, this beach is calm and cool, with the salty waves roaring softly in the background. \
	Comes with a rustic wooden bar and suicidal bartender."
	suffix = "lavaland_biodome_beach.dmm"

/datum/map_template/ruin/lavaland/seed_vault
	name = "Seed Vault"
	id = "seed-vault"
	description = "The creators of these vaults were a highly advanced and benevolent race, and launched many into the stars, hoping to aid fledgling civilizations. \
	However, all the inhabitants seem to do is grow drugs and guns."
	suffix = "lavaland_surface_seed_vault.dmm"
	cost = 10
	allow_duplicates = FALSE

datum/map_template/ruin/lavaland/ash_walker
	name = "Ash Walker Nest"
	id = "ash-walker"
	description = "A race of unbreathing lizards live here, that run faster than a human can, worship a broken dead city, and are capable of reproducing by something involving tentacles? \
	Probably best to stay clear."
	suffix = "lavaland_surface_ash_walker1.dmm"
	cost = 20
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/syndicate_base
	name = "Syndicate Lava Base"
	id = "lava-base"
	description = "A secret base researching illegal bioweapons, it is closely guarded by an elite team of syndicate agents."
	suffix = "lavaland_surface_syndicate_base1.dmm"
	cost = 20
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/animal_hospital
	name = "Animal Hospital"
	id = "animal-hospital"
	description = "Rats with cancer do not live very long. And the ones that wake up from cryostasis seem to commit suicide out of boredom."
	cost = 5
	suffix = "lavaland_surface_animal_hospital.dmm"
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/hierophant
	name = "Hierophant's Arena"
	id = "hierophant"
	description = "A strange, square chunk of metal of massive size. Inside awaits only death and many, many squares."
	suffix = "lavaland_surface_hierophant.dmm"
	allow_duplicates = FALSE
	always_place = TRUE

/datum/map_template/ruin/lavaland/blood_drunk_miner
	name = "Blood-Drunk Miner"
	id = "blooddrunk"
	description = "A strange arrangement of stone tiles and an insane, beastly miner contemplating them."
	suffix = "lavaland_surface_blooddrunk1.dmm"
	cost = 0
	allow_duplicates = FALSE //will only spawn one variant of the ruin

/datum/map_template/ruin/lavaland/blood_drunk_miner/guidance
	name = "Blood-Drunk Miner (Guidance)"
	suffix = "lavaland_surface_blooddrunk2.dmm"

/datum/map_template/ruin/lavaland/blood_drunk_miner/hunter
	name = "Blood-Drunk Miner (Hunter)"
	suffix = "lavaland_surface_blooddrunk3.dmm"

/datum/map_template/ruin/lavaland/hermit
	name = "Makeshift Shelter"
	id = "hermitcave"
	description = "A place of shelter for a lone hermit, scraping by to live another day."
	suffix = "lavaland_surface_hermit.dmm"
	allow_duplicates = FALSE
	cost = 10

/datum/map_template/ruin/lavaland/swarmer_boss
	name = "Crashed Shuttle"
	id = "swarmerboss"
	description = "A Syndicate shuttle had an unfortunate stowaway..."
	suffix = "lavaland_surface_swarmer_crash.dmm"
	allow_duplicates = FALSE
	cost = 20