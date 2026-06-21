//Languages/species/whitelist. //Languages and species fit with mobs right
GLOBAL_LIST_EMPTY(all_species)
GLOBAL_LIST_EMPTY(all_languages)
GLOBAL_LIST_EMPTY(language_keys)					// Table of say codes for all languages
GLOBAL_LIST_EMPTY(all_superheroes)

GLOBAL_LIST_EMPTY(clients)							//list of all clients
GLOBAL_LIST_EMPTY(persistent_clients)				// list of all persistent clients, used for reattaching when someone reconnects
GLOBAL_LIST_EMPTY(admins)							//list of all clients whom are admins
GLOBAL_LIST_EMPTY(de_admins)							//list of all admins who have used the de-admin verb.
GLOBAL_LIST_EMPTY(de_mentors)							//list of all mentors who have used the de-admin verb.
GLOBAL_LIST_EMPTY(directory)							//list of all ckeys with associated client
GLOBAL_LIST_EMPTY(stealthminID)						//reference list with IDs that store ckeys, for stealthmins

//Since it didn't really belong in any other category, I'm putting this here
//This is for procs to replace all the goddamn 'in world's that are chilling around the code

GLOBAL_LIST_EMPTY(player_list)				//List of all mobs **with clients attached**. Excludes /mob/new_player
GLOBAL_LIST_EMPTY(new_player_mobs)				// List of all new player mobs in the lobby
GLOBAL_LIST_EMPTY(mob_list)					//List of all mobs, including clientless
GLOBAL_LIST_EMPTY(silicon_mob_list)			//List of all silicon mobs, including clientless
GLOBAL_LIST_EMPTY(mob_living_list)			//all instances of /mob/living and subtypes
GLOBAL_LIST_EMPTY(carbon_list)				//all instances of /mob/living/carbon and subtypes, notably does not contain simple animals
GLOBAL_LIST_EMPTY(human_list)				//all instances of /mob/living/carbon/human and subtypes
GLOBAL_LIST_EMPTY(alive_mob_list)			//List of all alive mobs, including clientless. Excludes /mob/new_player
GLOBAL_LIST_EMPTY(alive_megafauna_list)     //List of all living megafauna
GLOBAL_LIST_EMPTY(dead_mob_list)				//List of all dead mobs, including clientless. Excludes /mob/new_player
GLOBAL_LIST_EMPTY(non_respawnable_keys)	//List of ckeys that are excluded from respawning for remainder of round.
GLOBAL_LIST_INIT(simple_animals, list(list(), list(), list(), list()))			//One for each AI_* status define, List of all simple animals, including clientless
GLOBAL_LIST_EMPTY(bots_list) 					//List of all bots(beepsky, medibots,etc)
GLOBAL_LIST_EMPTY(roundstart_observer_keys)	//List of ckeys who ghosted before the game began.
GLOBAL_LIST_EMPTY(antag_hud_users) 			// ckeys of users who have enabled ahud at some point during the game
GLOBAL_LIST_EMPTY(crew_list) 			// list of all crew on manifest, contains name paired with their assignment
GLOBAL_LIST_EMPTY(station_pets)			// List of all station pets.

GLOBAL_LIST_EMPTY(surgeries_list)
GLOBAL_LIST_EMPTY(hear_radio_list)			//Mobs that hear the radio even if there's no client

GLOBAL_LIST_EMPTY(emote_list)

/// Blacklist of types that swarmers should not touch
GLOBAL_LIST_INIT(swarmer_blacklist, list(
	/obj/item/gun,
	/turf/simulated/floor,
	/obj/structure/swarmer,
	/obj/structure/flora,
	/turf/simulated/wall/indestructible,
	/obj/machinery/atmospherics,
	/obj/structure/particle_accelerator,
	/obj/machinery/field/generator,
	/obj/machinery/chem_dispenser,
	/obj/machinery/nuclearbomb,
	/obj/structure/reagent_dispensers/fueltank,
	/obj/structure/cable,
	/obj/structure/fans/tiny,
	/obj/structure/holosign/barrier/atmos,
	/obj/machinery/tcomms,
	/obj/machinery/message_server,
	/obj/machinery/blackbox_recorder,
	/obj/machinery/power,
	/obj/machinery/cryopod,
	/obj/item/mmi,
	/obj/item/organ/internal/brain,
	/obj/machinery/computer/cryopod,
	/obj/machinery/porta_turret,
	/obj/machinery/clonepod,
	/obj/structure/shuttle/engine,
	/obj/machinery/hydroponics/soil,
	/obj/machinery/field/containment,
	/obj/machinery/gravity_generator,
	/mob/living/basic/swarmer,
	/obj/item/stack/sheet/wood,
	/obj/structure/table_frame/wood,
	/obj/structure/signpost/wood,
	/obj/structure/spirit_board,
	/obj/structure/mineral_door/wood,
	/obj/structure/falsewall/wood,
	/obj/structure/dresser,
	/obj/structure/door_assembly/door_assembly_wood,
	/obj/machinery/door/airlock/wood,
	/obj/item/storage/bag/plants/seed_sorting_tray,
	/obj/structure/displaycase_chassis,
	/obj/item/shield/riot/buckler,
	/obj/item/popsicle_stick,
	/obj/item/nullrod/claymore/bostaff,
	/obj/item/melee/classic_baton,
	/obj/item/storage/fancy/cigars/cohiba,
	/obj/item/stack/tile/wood,
	/obj/item/clothing/shoes/sandal,
	/obj/item/melee/baseball_bat,
	/obj/item/reagent_containers/glass/bucket/wooden,
	/obj/item/cultivator/rake,
	/obj/item/mounted/noticeboard,
	/obj/item/reagent_containers/drinks/mug/wood,
	/obj/item/match/firebrand,
	/obj/structure/chair/wood,
	/obj/structure/barricade/wooden,
	/obj/structure/chair/stool/wood,
	/obj/structure/bookcase,
	/obj/structure/spear_rack,
	/obj/structure/bed/wood,
	/obj/structure/bed/dogbed,
	/obj/structure/closet/coffin,
	/obj/structure/lightable/torch,
	/obj/structure/shelf/wood,
	/obj/structure/chair/sofa/pew,
	/obj/machinery/smartfridge/drying_rack,
	/obj/item/weaponcrafting/stock,
	/obj/structure/beebox,
	/obj/item/honey_frame,
	/obj/structure/ore_box,
	/obj/structure/loom,
	/obj/structure/fermenting_barrel,
	/obj/machinery/compost_bin,
	/obj/structure/roulette,
))

// Dear God
GLOBAL_LIST_INIT(migo_sounds, list(
	'sound/items/bubblewrap.ogg', 'sound/items/change_jaws.ogg', 'sound/items/crowbar.ogg', 'sound/items/drink.ogg',
	'sound/items/deconstruct.ogg', 'sound/items/change_drill.ogg', 'sound/items/dodgeball.ogg', 'sound/items/eatfood.ogg', 'sound/items/screwdriver.ogg',
	'sound/items/weeoo1.ogg', 'sound/items/wirecutter.ogg', 'sound/items/welder.ogg', 'sound/items/zip.ogg', 'sound/items/rped.ogg', 'sound/items/ratchet.ogg',
	'sound/items/polaroid1.ogg', 'sound/items/pshoom.ogg', 'sound/items/airhorn.ogg', 'sound/voice/bcreep.ogg', 'sound/voice/biamthelaw.ogg', 'sound/voice/ed209_20sec.ogg',
	'sound/voice/hiss3.ogg', 'sound/voice/hiss6.ogg', 'sound/voice/mpatchedup.ogg', 'sound/voice/mfeelbetter.ogg', 'sound/weapons/sear.ogg', 'sound/ambience/antag/tatoralert.ogg',
	'sound/mecha/nominal.ogg', 'sound/mecha/weapdestr.ogg', 'sound/mecha/critdestr.ogg', 'sound/mecha/imag_enh.ogg', 'sound/effects/adminhelp.ogg', 'sound/effects/alert.ogg',
	'sound/effects/attackblob.ogg', 'sound/effects/bamf.ogg', 'sound/effects/blobattack.ogg', 'sound/effects/break_stone.ogg', 'sound/effects/bubbles.ogg',
	'sound/effects/bubbles2.ogg', 'sound/effects/clang.ogg', 'sound/effects/clownstep2.ogg', 'sound/effects/dimensional_rend.ogg', 'sound/effects/doorcreaky.ogg',
	'sound/effects/empulse.ogg', 'sound/effects/explosionfar.ogg', 'sound/effects/explosion1.ogg', 'sound/effects/grillehit.ogg', 'sound/effects/genetics.ogg',
	'sound/effects/heartbeat.ogg', 'sound/effects/hyperspace_begin.ogg', 'sound/effects/hyperspace_end.ogg', 'sound/goonstation/effects/screech.ogg', 'sound/effects/phasein.ogg',
	'sound/effects/picaxe1.ogg', 'sound/effects/sparks1.ogg', 'sound/effects/smoke.ogg', 'sound/effects/splat.ogg', 'sound/effects/snap.ogg', 'sound/effects/tendril_destroyed.ogg',
	'sound/effects/supermatter.ogg', 'sound/misc/desceration-01.ogg', 'sound/misc/desceration-02.ogg', 'sound/misc/desceration-03.ogg', 'sound/misc/bloblarm.ogg',
	'sound/goonstation/misc/airraid_loop.ogg', 'sound/misc/interference.ogg', 'sound/misc/notice1.ogg', 'sound/misc/notice2.ogg', 'sound/misc/sadtrombone.ogg', 'sound/misc/slip.ogg',
	'sound/weapons/armbomb.ogg', 'sound/weapons/chainsaw.ogg', 'sound/weapons/emitter.ogg', 'sound/weapons/emitter2.ogg', 'sound/weapons/blade1.ogg', 'sound/weapons/bladeslice.ogg',
	'sound/weapons/blastcannon.ogg', 'sound/weapons/blaster.ogg', 'sound/weapons/bulletflyby3.ogg', 'sound/weapons/circsawhit.ogg', 'sound/weapons/cqchit2.ogg', 'sound/weapons/drill.ogg',
	'sound/weapons/genhit1.ogg', 'sound/weapons/gunshots/gunshot_silenced.ogg', 'sound/weapons/gunshots/gunshot.ogg', 'sound/weapons/handcuffs.ogg', 'sound/weapons/homerun.ogg',
	'sound/weapons/kenetic_accel.ogg','sound/machines/fryer/deep_fryer_emerge.ogg', 'sound/machines/airlock_alien_prying.ogg', 'sound/machines/airlock_close.ogg',
	'sound/machines/airlockforced.ogg', 'sound/machines/airlock_open.ogg', 'sound/machines/alarm.ogg', 'sound/machines/blender.ogg', 'sound/machines/boltsdown.ogg',
	'sound/machines/boltsup.ogg', 'sound/machines/buzz-sigh.ogg', 'sound/machines/buzz-two.ogg', 'sound/machines/chime.ogg', 'sound/machines/defib_charge.ogg',
	'sound/machines/defib_failed.ogg', 'sound/machines/defib_ready.ogg', 'sound/machines/defib_zap.ogg', 'sound/machines/deniedbeep.ogg', 'sound/machines/ding.ogg',
	'sound/machines/disposalflush.ogg', 'sound/machines/door_close.ogg', 'sound/machines/door_open.ogg', 'sound/machines/engine_alert1.ogg', 'sound/machines/engine_alert2.ogg',
	'sound/machines/hiss.ogg', 'sound/machines/honkbot_evil_laugh.ogg', 'sound/machines/juicer.ogg', 'sound/machines/ping.ogg', 'sound/ambience/signal.ogg', 'sound/machines/synth_no.ogg',
	'sound/machines/synth_yes.ogg', 'sound/machines/terminal_alert.ogg', 'sound/machines/twobeep.ogg', 'sound/machines/ventcrawl.ogg', 'sound/machines/warning-buzzer.ogg',
	'sound/ai/outbreak5.ogg', 'sound/ai/outbreak7.ogg', 'sound/ai/alert.ogg', 'sound/ai/radiation.ogg', 'sound/ai/eshuttle_call.ogg', 'sound/ai/eshuttle_dock.ogg',
	'sound/ai/eshuttle_recall.ogg', 'sound/ai/aimalf.ogg', 'sound/ambience/ambigen1.ogg', 'sound/ambience/ambigen3.ogg', 'sound/ambience/ambigen4.ogg', 'sound/ambience/ambigen5.ogg',
	'sound/ambience/ambigen6.ogg', 'sound/ambience/ambigen10.ogg', 'sound/hallucinations/over_here1.ogg', 'sound/hallucinations/over_here2.ogg', 'sound/hallucinations/over_here3.ogg',
	))
