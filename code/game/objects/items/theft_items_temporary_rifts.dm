
/// The number of anomalous particulate gatherings per objective
#define NUM_ANOM_PER_OBJ 5

//qwertodo: Decide if you want brain damage, eye damage, burning if moving into it, radioactive, or a combination of these things


/datum/anomalous_particulate_tracker
	/// The total number of gatherings that have been drained, for tracking.
	var/num_drained = 0
	/// List of tracked influences (reality smashes)
	var/list/obj/effect/anomalous_particulate/smashes = list()
	/// List of minds with the objective to get particulate
	var/list/datum/mind/tracked_objectiveholders = list()

/datum/anomalous_particulate_tracker/Destroy(force)
	if(GLOB.anomaly_smash_track == src)
		stack_trace("[type] was deleted. Antagonists may no longer access any particulate. Fix it, or call coder support.")
		message_admins("The [type] was deleted. Antagonists may no longer access any particulate. Fix it, or call coder support.")
	QDEL_LIST_CONTENTS(smashes)
	tracked_objectiveholders.Cut()
	return ..()

/**
 * Generates a set amount of reality smashes
 * based on the number of already existing smashes
 * and the number of minds we're tracking.
 */
/datum/anomalous_particulate_tracker/proc/generate_new_influences()
	var/how_many_can_we_make = 0
	for(var/heretic_number in 1 to length(tracked_objectiveholders))
		how_many_can_we_make += max(NUM_ANOM_PER_OBJ - heretic_number + 1, 1)

	var/location_sanity = 0
	while((length(smashes) + num_drained) < how_many_can_we_make && location_sanity < 100)
		var/turf/chosen_location = get_safe_random_station_turf_equal_weight()

		// We don't want them close to each other - at least 1 tile of separation
		var/list/nearby_things = range(1, chosen_location)
		var/obj/effect/anomalous_particulate/what_if_i_have_one = locate() in nearby_things
		var/obj/effect/visible_anomalous_particulate/what_if_i_had_one_but_its_used = locate() in nearby_things
		if(what_if_i_have_one || what_if_i_had_one_but_its_used)
			location_sanity++
			continue

		new /obj/effect/anomalous_particulate(chosen_location)

/**
 * Adds a mind to the list of people that need things spawned
 *
 * Use this whenever you want to add someone to the list
 */
/datum/anomalous_particulate_tracker/proc/add_tracked_mind(datum/mind/obj_mind)
	tracked_objectiveholders |= obj_mind

	// If our holder is on station, generate some new influences
	if(ishuman(obj_mind.current) && is_teleport_allowed(obj_mind.current.z))
		generate_new_influences()

/**
 * Removes a mind from the list of people that need things spawned
 *
 * Use this whenever you want to remove someone from the list
 */
/datum/anomalous_particulate_tracker/proc/remove_tracked_mind(datum/mind/obj_mind)
	tracked_objectiveholders -= obj_mind

/obj/effect/visible_anomalous_particulate
	name = "cloud of anomalous_particulate"
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "pierced_illusion" // qwertodo Temporary, will need it's own proper sprite in the event heretic does happen one day.
	anchored = TRUE
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	alpha = 0
	invisibility = INVISIBILITY_LEVEL_TWO

/obj/effect/visible_anomalous_particulate/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(show_presence)), 15 SECONDS)

/obj/effect/visible_anomalous_particulate/add_filter(name, priority, list/params)
	return

/*
 * Makes the influence fade in after 15 seconds.
 */
/obj/effect/visible_anomalous_particulate/proc/show_presence()
	invisibility = 0
	animate(src, alpha = 255, time = 15 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(fade_presence)), 15 SECONDS)

/*
 * Makes the influence fade out over 20 minutes.
 */
/obj/effect/visible_anomalous_particulate/proc/fade_presence()
	animate(src, alpha = 0, time = 20 MINUTES)
	QDEL_IN(src, 20 MINUTES)

/obj/effect/visible_anomalous_particulate/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!ishuman(user))
		return

	if(isAntag(user))
		to_chat(user, "<span class='boldwarning'>You feel that the manual suggested against touching active clouds!</span>")
		return TRUE
	// qwertodo: appropreate punishment for touching depending on type
	return TRUE

/obj/effect/visible_anomalous_particulate/examine(mob/user)
	. = ..()
	if(hasHUD(user, ANOMALOUS_HUD) || !ishuman(user))
		return

	var/mob/living/carbon/human/human_user = user
	to_chat(human_user, "<span class='userdanger'>Your mind burns as you stare at the tear!</span>")
	human_user.adjustBrainLoss(10) // qwertodo: eye damage too from looking directly at it?

/obj/effect/visible_anomalous_particulate/add_fingerprint(mob/living/M, ignoregloves)
	return //No detective you can not scan the fucking influence to find out who touched it

/obj/effect/anomalous_particulate
	name = "cloud of anomalous particulate"
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "reality_smash"
	anchored = TRUE
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	invisibility = INVISIBILITY_LEVEL_TWO
	hud_possible = list(ANOMALOUS_HUD)
	/// Whether we're currently being drained or not.
	var/being_drained = FALSE

/obj/effect/anomalous_particulate/Initialize(mapload)
	. = ..()
	GLOB.anomaly_smash_track.smashes += src
	prepare_huds()
	for(var/datum/atom_hud/data/anomalous/a_hud in GLOB.huds)
		a_hud.add_to_hud(src)
	do_hud_stuff()

/obj/effect/anomalous_particulate/Destroy()
	GLOB.anomaly_smash_track.smashes -= src
	return ..()

/obj/effect/anomalous_particulate/add_fingerprint(mob/living/M, ignoregloves)
	return //No detective you can not scan the fucking influence to find out who touched it

/obj/effect/anomalous_particulate/attack_by(obj/item/attacking, mob/user, params)
	if(..())
		return FINISH_ATTACK
	// Using a codex will give you two knowledge points for draining.
	if(drain_with_device(user, attacking))
		return FINISH_ATTACK
	return ..()

/obj/effect/anomalous_particulate/proc/drain_with_device(mob/user, obj/item/ppp_processor/processor) //qwertodo: the item
	if(!istype(processor) || being_drained)
		return FALSE
	//qwertodo : tie to item here
	INVOKE_ASYNC(src, PROC_REF(drain_influence), user, processor)
	return TRUE

/**
 * Begin to drain the influence, setting being_drained,
 * registering an examine signal, and beginning a do_after.
 *
 * If successful, the influence is drained and deleted.
 */
/obj/effect/anomalous_particulate/proc/drain_influence(mob/living/user, obj/item/ppp_processor/processor)
	if(processor.clouds_processed >= 3)
		to_chat(user, "<span class='warning'>Your PPPProcessor is full!</span>")
		return
	if(processor.clouds_processed == -1)
		to_chat(user, "<span class='warning'>Your PPPProcessor has no canisters to collect particulate with!</span>")
		return
	being_drained = TRUE
	to_chat(user, "<span class='notice'>Your PPPProcessor begins to energize and collect [src]...</span>")

	if(!do_after(user, 10 SECONDS, target = src, hidden = TRUE))
		being_drained = FALSE
		return

	// Aaand now we delete it
	after_drain(user, processor)

/**
 * Handle the effects of the drain.
 */
/obj/effect/anomalous_particulate/proc/after_drain(mob/living/user, obj/item/ppp_processor/processor)
	if(user)
		to_chat(user, "<span class='warning'>[src] begins to intensify!</span>")

	new /obj/effect/visible_anomalous_particulate(drop_location())

	processor.collect()

	GLOB.anomaly_smash_track.num_drained++
	qdel(src)

#undef NUM_ANOM_PER_OBJ

// This device is used to analyze and trigger the particulate
/obj/item/ppp_processor
	name = "Prototype Portable Particulate Processor"
	desc = "The Prototype Portable Particulate Processor, or PPPProcessor, for short, is a device designed to energize, collect, \
	and analyse anomalous particulate"
	icon = 'icons/obj/theft_tools.dmi' //qwertodo: sprite
	icon_state = "core_container_sealed"
	new_attack_chain = TRUE
	/// How many clouds have been processed?
	var/clouds_processed = 0

/obj/item/ppp_processor/proc/collect()
	clouds_processed++

/obj/item/clothing/glasses/hud/anomalous
	name = "anomalous particulate scanner HUD"
	desc = "A heads-up display that scans for anomalous particulate. Has a built in cham function, to help it blend in."
	icon_state = "sunhudmed"
	inhand_icon_state = "sunglasses"
	hud_types = DATA_HUD_ANOMALOUS
	flash_protect = FLASH_PROTECTION_FLASH // The revealed stuff often can cause eye flashes, safety first

	var/datum/action/item_action/chameleon_change/chameleon_action

/obj/item/clothing/glasses/hud/anomalous/Initialize(mapload)
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/glasses
	chameleon_action.chameleon_name = "HUD"
	chameleon_action.chameleon_blacklist = list()
	chameleon_action.initialize_disguises()

/obj/item/clothing/glasses/hud/anomalous/Destroy()
	QDEL_NULL(chameleon_action)
	return ..()

/obj/item/clothing/glasses/hud/anomalous/emp_act(severity)
	. = ..()
	chameleon_action.emp_randomise()

// The parent anomalous grenade type. Spawns a random anomaly.
/obj/item/grenade/anomalous_canister
	name = "anomalous particulate canister"
	desc = "This canister can be set off to unleash an anomaly." //qwertodo: improve
	icon_state = "emp"
	inhand_icon_state = "emp"
	origin_tech = "magnets=3;combat=2" //qwertodo: buff a little
	/// The type of anomaly the canister will spawn.
	var/obj/effect/anomaly/anomaly_type
	/// The lifetime of the anomaly.
	var/anomaly_lifetime = 45 SECONDS
	/// How many anomalies the grenade will spawn
	var/number_of_anomalies = 1

/obj/item/grenade/anomalous_canister/Initialize(mapload)
	. = ..()
	anomaly_type = pick(subtypesof(/obj/effect/anomaly))

/obj/item/grenade/anomalous_canister/prime()
	update_mob()
	for(var/i in 1 to number_of_anomalies)
		var/obj/effect/anomaly/A = new anomaly_type(get_turf(src), anomaly_lifetime, FALSE)
		A.anomalous_canister_setup()
	qdel(src)

/obj/item/grenade/anomalous_canister/dual_core
	name = "dual clouded anomalous particulate canister"
	desc = "Two smaller clouds of particulate are in this canister."
	//icon state should have 2
	number_of_anomalies = 2
	anomaly_lifetime = 30 SECONDS

/obj/item/grenade/anomalous_canister/condensed
	name = "condesed anomalous particulate canister"
	desc = "A large cloud of resiliant particulate is in this canister."
	//icon state should have a bigger cloud
	anomaly_lifetime = 90 SECONDS

/obj/item/grenade/anomalous_canister/stabilized
	name = "stabilized anomalous particulate canister"
	desc = "The cloud of this particulate has stabilized enough for the computer to predict the anomaly it will condense into..."
	//icon state should have cloud colour match the result

/obj/item/grenade/anomalous_canister/stabilized/examine(mob/user)
	. = ..()
	. += "<span class='notice'>The predicted result is for the cloud to condense into \an [anomaly_type::name]!</span>"

/obj/item/paper/anomalous_particulate
	name = "Particulate gathering instructions"
	info = {"<b>Instructions on your new PPPProcessor and HUD</b><br>
	<br>
	First off, equip your glasses. You will need them to find the particulate. We heavily advise against losing them.<br>
	<br>
	This will allow you to identify the uncharged anomalous particulate aboard the station. It can be anywhere, stalk out rooms and or use cameras to find it.<br>
	<br>
	Afterwords, approach the particulate with the PPPProcessor, and use it on the particulate. It will charge and capture a sample of it.<br>
	<br>
	<b>Warning:</b> Charged particulate is dangerous. Wear the goggles and leave the area. Try not to get caught in doing so.<br>
	<br>
	After collecting 3 diffrent unique samples (We will not accept a sample another agent has collected), deploy the scanner by using it in hand in a secluded area.<br>
	<br>
	After a minute of transfering the information, your objective will be complete, and 3 collection cansiters should eject.<br>
	<br>
	Feel free to use the canisters however you wish, they should be effective weapons, though do write down the results for us.
	<br><hr>
	<font size =\"1\"><i>We are not liable for any health conditions you may recive from scanning particulate or using the canisters.</i></font>
"}
/obj/item/storage/box/syndie_kit/anomalous_particulate
	name = "anomalous particulate processing kit"

/obj/item/storage/box/syndie_kit/anomalous_particulate/populate_contents()
	new /obj/item/ppp_processor(src)
	new /obj/item/clothing/glasses/hud/anomalous(src)
	new /obj/item/paper/anomalous_particulate(src)
