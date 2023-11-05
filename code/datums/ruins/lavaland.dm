/datum/map_template/ruin/lavaland
	prefix = "_maps/map_files/RandomRuins/LavaRuins/"
	ci_exclude = /datum/map_template/ruin/lavaland

/datum/map_template/ruin/lavaland/biodome
	cost = 5
	allow_duplicates = FALSE
	ci_exclude = /datum/map_template/ruin/lavaland/biodome // This is a parent holder, not a ruin itself

/datum/map_template/ruin/lavaland/biodome/winter
	name = "Biodome Winter"
	id = "biodome-winter"
	description = "For those getaways where you want to get back to nature, but you don't want to leave the fortified military compound where you spend your days. \
	Includes the recently introduced I.C.E(tm)."
	suffix = "lavaland_biodome_winter.dmm"

/datum/map_template/ruin/lavaland/biodome/clown
	name = "Biodome Clown Planet"
	id = "biodome-clown"
	description = "WELCOME TO CLOWN PLANET! HONK HONK HONK etc.!"
	suffix = "lavaland_biodome_clown_planet.dmm"

/datum/map_template/ruin/lavaland/seed_vault
	name = "Seed Vault"
	id = "seed-vault"
	description = "The creators of these vaults were a highly advanced and benevolent race, and launched many into the stars, hoping to aid fledgling civilizations. \
	However, all the inhabitants seem to do is grow drugs and explosives."
	suffix = "lavaland_surface_seed_vault.dmm"
	allow_duplicates = FALSE
	always_place = TRUE

/datum/map_template/ruin/lavaland/ash_walker
	name = "Ash Walker Nest"
	id = "ash-walker"
	description = "A race of unbreathing lizards live here, that run faster than a human can, worship a broken dead city, and are capable of reproducing by something involving tentacles? \
	Probably best to stay clear."
	suffix = "lavaland_surface_ash_walker1.dmm"
	allow_duplicates = FALSE
	cost = 20 // Not auto due to the nature of walkers

/datum/map_template/ruin/lavaland/free_golem
	name = "Free Golem Ship"
	id = "golem-ship"
	description = "Lumbering humanoids, made out of precious metals, move inside this ship. They frequently leave to mine more minerals, which they somehow turn into more of them. \
	Seem very intent on research and individual liberty, and also geology based naming?"
	suffix = "lavaland_surface_golem_ship.dmm"
	allow_duplicates = FALSE
	always_place = TRUE

/datum/map_template/ruin/lavaland/althland_facility
	name = "Althland Facility"
	id = "althland-facility"
	description = "A grim testament to the Althland Mining Company's ambitions, this facility lies in ruin, swallowed by the very planet it sought to exploit. \
	Once a beacon of mining promise, it now stands as a stark reminder of the company's catastrophic demise."
	cost = 5
	suffix = "lavaland_surface_althland_facility.dmm"
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/althland_excavation
	name = "Althland Excavation"
	id = "althland-excavation"
	description = "An abandoned mining pit, once operated by the late Althland Mining Corporation, stands as a testament to the extensive efforts of numerous labor groups who endeavored to exploit the ore-rich depths of the planet.  \
	Now, it lies abandoned, wholly reclaimed by the hostile environment, transforming into yet another relic of a lost company."
	cost = 5
	suffix = "lavaland_surface_althland_excavation.dmm"
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/sin
	cost = 10
	allow_duplicates = FALSE
	ci_exclude = /datum/map_template/ruin/lavaland/sin // This is a parent holder, not a ruin itself

/datum/map_template/ruin/lavaland/sin/envy
	name = "Ruin of Envy"
	id = "envy"
	description = "When you get what they have, then you'll finally be happy."
	suffix = "lavaland_surface_envy.dmm"

/datum/map_template/ruin/lavaland/sin/gluttony
	name = "Ruin of Gluttony"
	id = "gluttony"
	description = "If you eat enough, then eating will be all that you do."
	suffix = "lavaland_surface_gluttony.dmm"

/datum/map_template/ruin/lavaland/sin/greed
	name = "Ruin of Greed"
	id = "greed"
	description = "Sure you don't need magical powers, but you WANT them, and that's what's important."
	suffix = "lavaland_surface_greed.dmm"

/datum/map_template/ruin/lavaland/sin/pride
	name = "Ruin of Pride"
	id = "pride"
	description = "Wormhole lifebelts are for LOSERS, who you are better than."
	suffix = "lavaland_surface_pride.dmm"

/datum/map_template/ruin/lavaland/sin/sloth
	name = "Ruin of Sloth"
	id = "sloth"
	description = "..."
	suffix = "lavaland_surface_sloth.dmm"
	cost = 0

/datum/map_template/ruin/lavaland/ratvar
	name = "Dead God"
	id = "ratvar"
	description = "Ratvars final resting place."
	suffix = "lavaland_surface_dead_ratvar.dmm"
	cost = 0
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/hierophant
	name = "Hierophant's Arena"
	id = "hierophant"
	description = "A strange, square chunk of metal of massive size. Inside awaits only death and many, many squares."
	suffix = "lavaland_surface_hierophant.dmm"
	always_place = TRUE
	allow_duplicates = FALSE

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

/datum/map_template/ruin/lavaland/ufo_crash
	name = "UFO Crash"
	id = "ufo-crash"
	description = "Turns out that keeping your abductees unconscious is really important. Who knew?"
	suffix = "lavaland_surface_ufo_crash.dmm"
	cost = 5

/datum/map_template/ruin/lavaland/xeno_nest
	name = "Xenomorph Nest"
	id = "xeno-nest"
	description = "These xenomorphs got bored of horrifically slaughtering people on space stations, and have settled down on a nice lava filled hellscape to focus on what's really important in life. \
	Quality memes."
	suffix = "lavaland_surface_xeno_nest.dmm"
	cost = 20

/datum/map_template/ruin/lavaland/fountain
	name = "Fountain Hall"
	id = "fountain"
	description = "The fountain has a warning on the side. DANGER: May have undeclared side effects that only become obvious when implemented."
	suffix = "lavaland_surface_fountain_hall.dmm"
	cost = 5

/datum/map_template/ruin/lavaland/survivalcapsule
	name = "Survival Capsule Ruins"
	id = "survivalcapsule"
	description = "What was once sanctuary to the common miner, is now their tomb."
	suffix = "lavaland_surface_survivalpod.dmm"
	cost = 5

/datum/map_template/ruin/lavaland/pizza
	name = "Ruined Pizza Party"
	id = "pizza"
	description = "Little Timmy's birthday pizza-bash took a turn for the worse when a bluespace anomaly passed by."
	suffix = "lavaland_surface_pizzaparty.dmm"
	allow_duplicates = FALSE
	cost = 5

/datum/map_template/ruin/lavaland/cultaltar
	name = "Summoning Ritual"
	id = "cultaltar"
	description = "A place of vile worship, the scrawling of blood in the middle glowing eerily. A demonic laugh echoes throughout the caverns"
	suffix = "lavaland_surface_cultaltar.dmm"
	allow_duplicates = FALSE
	cost = 10

/datum/map_template/ruin/lavaland/hermit
	name = "Makeshift Shelter"
	id = "hermitcave"
	description = "A place of shelter for a lone hermit, scraping by to live another day."
	suffix = "lavaland_surface_hermit.dmm"
	allow_duplicates = FALSE
	always_place = TRUE

/datum/map_template/ruin/lavaland/miningripley
	name = "Ripley"
	id = "ripley"
	description = "A heavily-damaged mining ripley, property of a very unfortunate miner. You might have to do a bit of work to fix this thing up."
	suffix = "lavaland_surface_random_ripley.dmm"
	allow_duplicates = FALSE
	cost = 5

/datum/map_template/ruin/lavaland/puzzle
	name = "Ancient Puzzle"
	id = "puzzle"
	description = "Mystery to be solved."
	suffix = "lavaland_surface_puzzle.dmm"
	cost = 5

/datum/map_template/ruin/lavaland/tumor
	name = "Elite Tumor"
	id = "tumor"
	description = "The victor freed, the loser the next fighter. The ghosts, the endless spectators. And thus the cycle loops..."
	suffix = "lavaland_surface_elite_tumor.dmm"
	cost = 5
	always_place = TRUE

/datum/map_template/ruin/lavaland/monster_nest
	name = "Monster Nest"
	id = "monsternest"
	description = "A cave of several tunnels, housing the local fauna deep underground."
	suffix = "lavaland_surface_monster_nest.dmm"
	allow_duplicates = FALSE
	cost = 5
