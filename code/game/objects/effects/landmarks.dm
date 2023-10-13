/obj/effect/landmark
	name = "landmark"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "x2"
	layer = MOB_LAYER
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/effect/landmark/Initialize(mapload)
	. = ..()
	set_tag()
	invisibility = 101
	GLOB.landmarks_list += src

/obj/effect/landmark/newplayer_start //There should only be one of these, in the lobby art area
	name = "start"

INITIALIZE_IMMEDIATE(/obj/effect/landmark/newplayer_start) //Without this you spawn in the corner of the map and things break horribly

/obj/effect/landmark/newplayer_start/Initialize(mapload)
	. = ..()
	GLOB.newplayer_start += loc
	qdel(src)

/obj/effect/landmark/lightsout
	name = "Electrical Storm Epicentre"

/obj/effect/landmark/awaystart
	name = "awaystart"
	icon = 'icons/effects/spawner_icons.dmi'
	icon_state = "Assistant"

INITIALIZE_IMMEDIATE(/obj/effect/landmark/awaystart) //Without this away missions break

/obj/effect/landmark/awaystart/Initialize(mapload)
	GLOB.awaydestinations.Add(src)
	return ..()

/obj/effect/landmark/spawner
	icon = 'icons/effects/spawner_icons.dmi'
	icon_state = "questionmark"
	var/spawner_list

/obj/effect/landmark/spawner/Initialize(mapload)
	. = ..()
	if(spawner_list)
		spawner_list += loc
		return INITIALIZE_HINT_QDEL

/obj/effect/landmark/spawner/soltrader
	name = "traderstart_sol"
	icon_state = "Trader"

/obj/effect/landmark/spawner/ert
	name = "Response Team"
	icon_state = "ERT"

/obj/effect/landmark/spawner/ert/Initialize(mapload)
	spawner_list = GLOB.emergencyresponseteamspawn
	return ..()

/obj/effect/landmark/spawner/ds
	name = "Deathsquad"
	icon_state = "ERT"

/obj/effect/landmark/spawner/wiz
	name = "wizard"
	icon_state = "Wiz"

/obj/effect/landmark/spawner/wiz/Initialize(mapload)
	spawner_list = GLOB.wizardstart
	return ..()

/obj/effect/landmark/spawner/xeno
	name = "xeno_spawn"
	icon_state = "Xeno"

/obj/effect/landmark/spawner/xeno/Initialize(mapload)
	spawner_list = GLOB.xeno_spawn
	return ..()

/obj/effect/landmark/spawner/nukedisc_respawn
	name = "nukedisc_respawn"
	icon_state = "Nuke_disk"

/obj/effect/landmark/spawner/nukedisc_respawn/Initialize(mapload)
	spawner_list = GLOB.nukedisc_respawn
	return ..()

/obj/effect/landmark/spawner/late
	icon_state = "Assistant"

/obj/effect/landmark/spawner/late/crew
	name = "Late Join Crew"

/obj/effect/landmark/spawner/late/crew/Initialize(mapload)
	spawner_list = GLOB.latejoin
	return ..()

/obj/effect/landmark/spawner/carp
	name = "carpspawn"
	icon_state = "Carp"

/obj/effect/landmark/spawner/carp/Initialize(mapload)
	spawner_list = GLOB.carplist
	return ..()

/obj/effect/landmark/spawner/rev
	name = "revenantspawn"
	icon_state = "Rev"
	
/obj/effect/landmark/spawner/bubblegum_arena
	name = "bubblegum_arena_human"
	icon_state = "Explorer"

/obj/effect/landmark/spawner/bubblegum
	name = "bubblegum_arena_bubblegum"
	icon_state = "bubblegumjumpscare"

/obj/effect/landmark/spawner/bubblegum_exit
	name = "bubblegum_arena_exit"
	icon_state = "bubblegumjumpscare"

/obj/effect/landmark/spawner/syndie
	name = "Syndicate-Spawn"
	icon_state = "Syndie"

/obj/effect/landmark/spawner/syndicateofficer
	name = "Syndicate Officer"

/obj/effect/landmark/spawner/syndicateofficer/Initialize(mapload)
	spawner_list = GLOB.syndicateofficer
	return ..()

/obj/effect/landmark/spawner/ertdirector
	name = "ERT Director"

/obj/effect/landmark/spawner/ertdirector/Initialize(mapload)
	spawner_list = GLOB.ertdirector
	return ..()

/obj/effect/landmark/spawner/ninjastart
	name = "ninjastart"

/obj/effect/landmark/spawner/ninjastart/Initialize(mapload)
	spawner_list = GLOB.ninjastart
	return ..()

/obj/effect/landmark/spawner/aroomwarp
	name = "aroomwarp"

/obj/effect/landmark/spawner/aroomwarp/Initialize(mapload)
	spawner_list = GLOB.aroomwarp
	return ..()

/obj/effect/landmark/spawner/tdomeobserve
	name = "tdomeobserve"

/obj/effect/landmark/spawner/tdomeobserve/Initialize(mapload)
	spawner_list = GLOB.tdomeobserve
	return ..()

/obj/effect/landmark/spawner/tdomeadmin
	name = "tdomeadmin"

/obj/effect/landmark/spawner/tdomeadmin/Initialize(mapload)
	spawner_list = GLOB.tdomeadmin
	return ..()

/obj/effect/landmark/spawner/tdome2
	name = "tdome2"

/obj/effect/landmark/spawner/tdome2/Initialize(mapload)
	spawner_list = GLOB.tdome2
	return ..()

/obj/effect/landmark/spawner/tdome1
	name = "tdome1"

/obj/effect/landmark/spawner/tdome1/Initialize(mapload)
	spawner_list = GLOB.tdome1
	return ..()

/obj/effect/landmark/spawner/prisonsecuritywarp
	name = "prisonsecuritywarp"

/obj/effect/landmark/spawner/prisonsecuritywarp/Initialize(mapload)
	spawner_list = GLOB.prisonsecuritywarp
	return ..()

/obj/effect/landmark/spawner/syndieprisonwarp
	name = "syndieprisonwarp"

/obj/effect/landmark/spawner/syndieprisonwarp/Initialize(mapload)
	spawner_list = GLOB.syndieprisonwarp
	return ..()

/obj/effect/landmark/spawner/prisonwarp
	name = "prisonwarp"

/obj/effect/landmark/spawner/prisonwarp/Initialize(mapload)
	spawner_list = GLOB.prisonwarp
	return ..()

/obj/effect/landmark/spawner/syndicate_commando
	name = "Syndicate-Commando"
	icon_state = "Syndie"

/obj/effect/landmark/spawner/syndicate_infiltrator
	name = "Syndicate-Infiltrator"
	icon_state = "Syndie"

/obj/effect/landmark/spawner/syndicate_infiltrator_leader
	name = "Syndicate-Infiltrator-Leader"
	icon_state = "Syndie"

/obj/effect/landmark/spawner/atmos_test
	name = "Atmospheric Test Start"

/obj/effect/landmark/spawner/commando_manual
	name = "Deathsquad Commando Manual"

/obj/effect/landmark/spawner/holding_facility
	name = "Holding Facility"

/obj/effect/landmark/spawner/holocarp
	name = "Holocarp Spawn"

/obj/effect/landmark/spawner/nuclear_bomb
	icon_state = "Nuke_bomb"

/obj/effect/landmark/spawner/nuclear_bomb/syndicate
	name = "Syndicate Nuclear Bomb"

/obj/effect/landmark/spawner/nuclear_bomb/death_squad
	name = "Death Squad Nuclear Bomb"

/obj/effect/landmark/spawner/teleport_scroll
	name = "Teleport-Scroll"

/obj/effect/landmark/spawner/nuke_code
	name = "nukecode"

/obj/effect/landmark/Destroy()
	GLOB.landmarks_list -= src
	..()
	return QDEL_HINT_HARDDEL_NOW

/obj/effect/landmark/proc/set_tag()
	tag = text("landmark*[]", name)

/obj/effect/landmark/singularity_act()
	return

// Please stop bombing the Observer-Start landmark.
/obj/effect/landmark/ex_act()
	return

/obj/effect/landmark/singularity_pull()
	return

/obj/effect/landmark/start
	name = "start"
	icon = 'icons/effects/spawner_icons.dmi'
	icon_state = "Assistant"

/obj/effect/landmark/start/ai
	name = "AI"
	icon_state = "AI"

/obj/effect/landmark/start/assistant
	name = "Assistant"
	icon_state = "Assistant"

/obj/effect/landmark/start/atmospheric
	name = "Life Support Specialist"
	icon_state = "Atmos"

/obj/effect/landmark/start/blueshield
	name = "Blueshield"
	icon_state = "BS"

/obj/effect/landmark/start/barber
	name = "Barber"
	icon_state = "Barber"

/obj/effect/landmark/start/bartender
	name = "Bartender"
	icon_state = "Bartender"

/obj/effect/landmark/start/cyborg
	name = "Cyborg"
	icon_state = "Borg"

/obj/effect/landmark/start/botanist
	name = "Botanist"
	icon_state = "Botanist"

/obj/effect/landmark/start/chief_engineer
	name = "Chief Engineer"
	icon_state = "CE"

/obj/effect/landmark/start/chief_medical_officer
	name = "Chief Medical Officer"
	icon_state = "CMO"

/obj/effect/landmark/start/captain
	name = "Captain"
	icon_state = "Cap"

/obj/effect/landmark/start/cargo_technician
	name = "Cargo Technician"
	icon_state = "CargoTech"

/obj/effect/landmark/start/chaplain
	name = "Chaplain"
	icon_state = "Chap"

/obj/effect/landmark/start/chef
	name = "Chef"
	icon_state = "Chef"

/obj/effect/landmark/start/chemist
	name = "Chemist"
	icon_state = "Chemist"

/obj/effect/landmark/start/clown
	name = "Clown"
	icon_state = "Clown"

/obj/effect/landmark/start/coroner
	name = "Coroner"
	icon_state = "Coroner"

/obj/effect/landmark/start/detective
	name = "Detective"
	icon_state = "Det"

/obj/effect/landmark/start/explorer
	name = "Explorer"
	icon_state = "Explorer"

/obj/effect/landmark/start/engineer
	name = "Station Engineer"
	icon_state = "Engi"

/obj/effect/landmark/start/geneticist
	name = "Geneticist"
	icon_state = "Genetics"

/obj/effect/landmark/start/head_of_personnel
	name = "Head of Personnel"
	icon_state = "HoP"

/obj/effect/landmark/start/head_of_security
	name = "Head of Security"
	icon_state = "HoS"

/obj/effect/landmark/start/internal_affairs
	name = "Internal Affairs Agent"
	icon_state = "IAA"

/obj/effect/landmark/start/janitor
	name = "Janitor"
	icon_state = "Jani"

/obj/effect/landmark/start/librarian
	name = "Librarian"
	icon_state = "Librarian"

/obj/effect/landmark/start/doctor
	name = "Medical Doctor"
	icon_state = "MD"

/obj/effect/landmark/start/magistrate
	name = "Magistrate"
	icon_state = "Magi"

/obj/effect/landmark/start/mime
	name = "Mime"
	icon_state = "Mime"

/obj/effect/landmark/start/shaft_miner
	name = "Shaft Miner"
	icon_state = "Miner"

/obj/effect/landmark/start/nanotrasen_rep
	name = "Nanotrasen Representative"
	icon_state = "NTR"

/obj/effect/landmark/start/paramedic
	name = "Paramedic"
	icon_state = "Paramed"

/obj/effect/landmark/start/psychiatrist
	name = "Psychiatrist"
	icon_state = "Psych"

/obj/effect/landmark/start/quartermaster
	name = "Quartermaster"
	icon_state = "QM"

/obj/effect/landmark/start/research_director
	name = "Research Director"
	icon_state = "RD"

/obj/effect/landmark/start/roboticist
	name = "Roboticist"
	icon_state = "Robo"

/obj/effect/landmark/start/scientist
	name = "Scientist"
	icon_state = "Sci"

/obj/effect/landmark/start/security_officer
	name = "Security Officer"
	icon_state = "Sec"

/obj/effect/landmark/start/virologist
	name = "Virologist"
	icon_state = "Viro"

/obj/effect/landmark/start/warden
	name = "Warden"
	icon_state = "Warden"


/obj/effect/landmark/start/set_tag()
	tag = "start*[name]"


//Costume spawner landmarks

/obj/effect/landmark/costume/random/Initialize(mapload) //costume spawner, selects a random subclass and disappears
	. = ..()
	var/list/options = (typesof(/obj/effect/landmark/costume) - /obj/effect/landmark/costume/random)
	var/PICK= options[rand(1,options.len)]
	new PICK(src.loc)
	return INITIALIZE_HINT_QDEL

//SUBCLASSES.  Spawn a bunch of items and disappear likewise
/obj/effect/landmark/costume/chicken/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/suit/chickensuit(src.loc)
	new /obj/item/clothing/head/chicken(src.loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/gladiator/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/under/costume/gladiator(src.loc)
	new /obj/item/clothing/head/helmet/gladiator(src.loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/madscientist/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/under/misc/gimmick/rank/captain/suit(src.loc)
	new /obj/item/clothing/head/flatcap(src.loc)
	new /obj/item/clothing/suit/storage/labcoat/mad(src.loc)
	new /obj/item/clothing/glasses/gglasses(src.loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/elpresidente/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/under/misc/gimmick/rank/captain/suit(src.loc)
	new /obj/item/clothing/head/flatcap(src.loc)
	new /obj/item/clothing/mask/cigarette/cigar/havana(src.loc)
	new /obj/item/clothing/shoes/jackboots(src.loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/schoolgirl/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/under/dress/schoolgirl(src.loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/maid/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/under/dress/blackskirt(src.loc)
	var/CHOICE = pick( /obj/item/clothing/head/beret , /obj/item/clothing/head/rabbitears )
	new CHOICE(src.loc)
	new /obj/item/clothing/glasses/sunglasses/blindfold(src.loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/butler/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/suit/wcoat(src.loc)
	new /obj/item/clothing/under/suit/black(loc)
	new /obj/item/clothing/head/that(src.loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/scratch/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/gloves/color/white(src.loc)
	new /obj/item/clothing/shoes/white(src.loc)
	new /obj/item/clothing/under/misc/scratch(src.loc)
	if(prob(30))
		new /obj/item/clothing/head/cueball(src.loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/highlander/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/under/costume/kilt(src.loc)
	new /obj/item/clothing/head/beret(src.loc)
	qdel(src)

/obj/effect/landmark/costume/prig/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/suit/wcoat(src.loc)
	new /obj/item/clothing/glasses/monocle(src.loc)
	var/CHOICE= pick( /obj/item/clothing/head/bowlerhat, /obj/item/clothing/head/that)
	new CHOICE(src.loc)
	new /obj/item/clothing/shoes/black(src.loc)
	new /obj/item/cane(src.loc)
	new /obj/item/clothing/under/misc/sl_suit(src.loc)
	new /obj/item/clothing/mask/fakemoustache(src.loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/plaguedoctor/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/suit/bio_suit/plaguedoctorsuit(src.loc)
	new /obj/item/clothing/head/plaguedoctorhat(src.loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/nightowl/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/under/costume/owl(src.loc)
	new /obj/item/clothing/mask/gas/owl_mask(src.loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/waiter/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/under/misc/waiter(src.loc)
	var/CHOICE= pick( /obj/item/clothing/head/kitty, /obj/item/clothing/head/rabbitears)
	new CHOICE(src.loc)
	new /obj/item/clothing/suit/apron(src.loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/pirate/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/under/costume/pirate(src.loc)
	new /obj/item/clothing/suit/pirate_black(src.loc)
	var/CHOICE = pick( /obj/item/clothing/head/pirate , /obj/item/clothing/head/bandana )
	new CHOICE(src.loc)
	new /obj/item/clothing/glasses/eyepatch(src.loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/commie/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/under/costume/soviet(src.loc)
	new /obj/item/clothing/head/ushanka(src.loc)
	return INITIALIZE_HINT_QDEL


/obj/effect/landmark/costume/imperium_monk/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/suit/imperium_monk(src.loc)
	if(prob(25))
		new /obj/item/clothing/mask/gas/cyborg(src.loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/holiday_priest/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/suit/holidaypriest(src.loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/marisa_fakewizard/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/head/wizard/marisa/fake(src.loc)
	new/obj/item/clothing/suit/wizrobe/marisa/fake(src.loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/cutewitch/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/under/dress/sundress(src.loc)
	new /obj/item/clothing/head/witchwig(src.loc)
	new /obj/item/staff/broom(src.loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/fakewizard/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/suit/wizrobe/fake(src.loc)
	new /obj/item/clothing/head/wizard/fake(src.loc)
	new /obj/item/staff/(src.loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/sexyclown/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/mask/gas/clown_hat/sexy(loc)
	new /obj/item/clothing/under/rank/civilian/clown/sexy(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/sexymime/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/mask/gas/sexymime(src.loc)
	new /obj/item/clothing/under/rank/civilian/mime/sexy(src.loc)
	qdel(src)

/obj/effect/landmark/ruin
	var/datum/map_template/ruin/ruin_template

/obj/effect/landmark/ruin/New(loc, my_ruin_template)
	name = "ruin_[GLOB.ruin_landmarks.len + 1]"
	..(loc)
	ruin_template = my_ruin_template
	GLOB.ruin_landmarks |= src

/obj/effect/landmark/ruin/Destroy()
	GLOB.ruin_landmarks -= src
	ruin_template = null
	. = ..()


/// Mob spawners, spawns a mob and deletes the landmark

/obj/effect/landmark/mob_spawner
	///The mob we use for the spawner
	var/mobtype = null
	icon = 'icons/effects/spawner_icons.dmi'
	icon_state = "questionmark"

/obj/effect/landmark/mob_spawner/Initialize(mapload)
	. = ..()
	new mobtype(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/mob_spawner/goliath
	mobtype = /mob/living/simple_animal/hostile/asteroid/goliath/beast

/obj/effect/landmark/mob_spawner/goliath/Initialize(mapload)
	if(prob(1))
		mobtype = /mob/living/simple_animal/hostile/asteroid/goliath/beast/ancient
	. = ..()

/obj/effect/landmark/mob_spawner/legion
	mobtype = /mob/living/simple_animal/hostile/asteroid/hivelord/legion

/obj/effect/landmark/mob_spawner/legion/Initialize(mapload)
	if(prob(5))
		mobtype = /mob/living/simple_animal/hostile/asteroid/hivelord/legion/dwarf
	. = ..()

/obj/effect/landmark/mob_spawner/watcher
	mobtype = /mob/living/simple_animal/hostile/asteroid/basilisk/watcher

/obj/effect/landmark/mob_spawner/watcher/Initialize(mapload)
	if(prob(1))
		if(prob(25)) /// 75% chance to get a magmawing watcher, and 25% chance to get a icewing watcher (1/133, 1/400 respectively)
			mobtype = /mob/living/simple_animal/hostile/asteroid/basilisk/watcher/icewing
		else
			mobtype = /mob/living/simple_animal/hostile/asteroid/basilisk/watcher/magmawing
	. = ..()

/obj/effect/landmark/mob_spawner/goldgrub
	mobtype = /mob/living/simple_animal/hostile/asteroid/goldgrub

/obj/effect/landmark/mob_spawner/gutlunch
	mobtype = /mob/living/simple_animal/hostile/asteroid/gutlunch

/obj/effect/landmark/mob_spawner/gutlunch/Initialize(mapload)
	if(prob(5))
		mobtype = /mob/living/simple_animal/hostile/asteroid/gutlunch/gubbuck
	. = ..()

/obj/effect/landmark/mob_spawner/abandoned_minebot
	mobtype = /mob/living/simple_animal/hostile/asteroid/abandoned_minebot

// Damage tiles
/obj/effect/landmark/damageturf
	icon_state = "damaged"

/obj/effect/landmark/damageturf/Initialize(mapload)
	. = ..()
	var/turf/simulated/T = get_turf(src)
	if(istype(T))
		T.break_tile()

/obj/effect/landmark/burnturf
	icon_state = "burned"

/obj/effect/landmark/burnturf/Initialize(mapload)
	. = ..()
	var/turf/simulated/T = get_turf(src)
	T.burn_tile()

/obj/effect/landmark/battle_mob_point
	name = "Nanomob Battle Avatar Spawn Point"

/obj/effect/landmark/free_golem_spawn
	name = "Free Golem Spawn Point"
