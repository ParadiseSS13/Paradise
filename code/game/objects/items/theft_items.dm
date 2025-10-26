//Items for nuke theft, supermatter theft traitor objective
//the nuke core, base item
/obj/item/nuke_core
	name = "plutonium core"
	desc = "Extremely radioactive. Wear goggles."
	icon = 'icons/obj/theft_tools.dmi'
	icon_state = "plutonium_core"
	inhand_icon_state = "plutoniumcore"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	flags_2 = RAD_NO_CONTAMINATE_2 //This is made from radioactive material so cannot really be contaminated
	new_attack_chain = TRUE
	var/cooldown = 0
	var/pulseicon = "plutonium_core_pulse"
	// Is this made from radioactive material or not.
	var/radioactive_material = TRUE

/obj/item/nuke_core/Initialize(mapload)
	. = ..()
	if(radioactive_material)
		var/datum/component/inherent_radioactivity/radioactivity = AddComponent(/datum/component/inherent_radioactivity, 0, 400, 0, 1.5)
		START_PROCESSING(SSradiation, radioactivity)

/obj/item/nuke_core/Destroy()
	return ..()

/obj/item/nuke_core/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is rubbing [src] against [user.p_themselves()]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return TOXLOSS

// MARK: Plutonium core
/// The steal objective, so it doesnt mess with the SM sliver on pinpointers and objectives
/obj/item/nuke_core/plutonium

/obj/item/nuke_core/plutonium/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/high_value_item)

//nuke core box, for carrying the core
/obj/item/nuke_core_container
	name = "nuke core container"
	desc = "A lead-lined secure container produced by the Syndicate for the express purpose of extracting the valuable radioactive cores of nuclear weapons."
	icon = 'icons/obj/theft_tools.dmi'
	icon_state = "core_container_empty"
	inhand_icon_state = "syringe_kit"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF //Don't want people trying to break it open with acid, then destroying the core.
	var/obj/item/nuke_core/plutonium/core
	new_attack_chain = TRUE
	var/dented = FALSE
	var/cracked = FALSE

/obj/item/nuke_core_container/examine(mob/user)
	. = ..()
	if(cracked) // Cracked open.
		. += "<span class='warning'>It is broken, and can no longer store objects safely.</span>"
	else if(dented) // Not cracked, but dented.
		. += "<span class='notice'>[src] looks dented. Perhaps a bigger explosion may break it.</span>"
	else // Not cracked or dented.
		. += "<span class='notice'>Fine print on the box reads \"Syndicate Field Operations secure core extraction container. Guaranteed thermite proof, assistant proof, and explosive resistant.\"</span>"

/obj/item/nuke_core_container/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!istype(used, /obj/item/nuke_core/plutonium))
		return ..()

	var/obj/item/nuke_core/plutonium/core = used
	if(cracked)
		return ITEM_INTERACT_COMPLETE

	if(!user.drop_item())
		to_chat(user, "<span class='warning'>[core] is stuck to your hand!</span>")
		return ITEM_INTERACT_COMPLETE

	load(core, user)
	return ITEM_INTERACT_COMPLETE

/obj/item/nuke_core_container/attack_hand(mob/user)
	if(cracked && core)
		unload(user)
	else
		return ..()

/obj/item/nuke_core_container/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			if(!cracked)
				crack_open()
		if(EXPLODE_HEAVY)
			dented = TRUE

/obj/item/nuke_core_container/Destroy()
	QDEL_NULL(core)
	return ..()

/obj/item/nuke_core_container/proc/load(obj/item/nuke_core/plutonium/new_core, mob/user)
	if(core || !istype(new_core) || cracked)
		return
	new_core.forceMove(src)
	core = new_core
	icon_state = "core_container_loaded"
	to_chat(user, "<span class='warning'>Container is sealing...</span>")
	addtimer(CALLBACK(src, PROC_REF(seal)), 10 SECONDS)

/obj/item/nuke_core_container/proc/unload(mob/user)
	core.add_fingerprint(user)
	user.put_in_active_hand(core)
	core = null
	icon_state = "core_container_cracked_empty"

/obj/item/nuke_core_container/proc/seal()
	if(!QDELETED(core))
		var/datum/component/inherent_radioactivity/radioactivity = core.GetComponent(/datum/component/inherent_radioactivity)
		var/datum/component/radioactive/box_contamination = GetComponent(/datum/component/radioactive)
		STOP_PROCESSING(SSradiation, radioactivity)
		if(box_contamination)
			box_contamination.RemoveComponent()
		icon_state = "core_container_sealed"
		playsound(src, 'sound/items/deconstruct.ogg', 60, TRUE)
		if(ismob(loc))
			to_chat(loc, "<span class='warning'>[src] is permanently sealed, [core]'s radiation is contained.</span>")

/obj/item/nuke_core_container/proc/crack_open()
	visible_message("<span class='boldnotice'>[src] bursts open!</span>")
	if(core)
		var/datum/component/inherent_radioactivity/radioactivity = core.GetComponent(/datum/component/inherent_radioactivity)
		START_PROCESSING(SSradiation, radioactivity)
		icon_state = "core_container_cracked_loaded"
	else
		icon_state = "core_container_cracked_empty"
	name = "broken nuke core container"
	cracked = TRUE

/obj/item/paper/guides/antag/nuke_instructions
	info = "How to break into a Nanotrasen nuclear device and remove its plutonium core:<br>\
	<ul>\
	<li>Acquire some clothing that protects you from radiation, due to the radioactivity of the core.</li>\
	<li>Use a screwdriver with a very thin tip (provided) to unscrew the terminal's front panel.</li>\
	<li>Dislodge and remove the front panel with a crowbar.</li>\
	<li>Cut the inner metal plate with a welding tool.</li>\
	<li>Pry off the inner plate with a crowbar to expose the radioactive core.</li>\
	<li>Pull the core out of the nuclear device. </li>\
	<li>Put the core in the provided container, which will take some time to seal. </li>\
	<li>???</li>\
	</ul>"

// MARK: Supermatter sliver
/obj/item/paper/guides/antag/supermatter_sliver
	info = "How to safely extract a supermatter sliver:<br>\
	<ul>\
	<li>Approach an active supermatter crystal with radiation shielded personal protective equipment, and active magboots. DO NOT MAKE PHYSICAL CONTACT.</li>\
	<li>Use a supermatter scalpel (provided) to slice off a sliver of the crystal.</li>\
	<li>Use supermatter extraction tongs (also provided) to safely pick up the sliver you sliced off.</li>\
	<li>Physical contact of any object with the sliver will dust the object, as well as yourself.</li>\
	<li>Use the tongs to place the sliver into the provided container, which will take some time to seal.</li>\
	<li>Get the hell out before the crystal delaminates.</li>\
	<li>???</li>\
	</ul>"

/obj/item/nuke_core/supermatter_sliver
	name = "supermatter sliver"
	desc = "A tiny, highly volatile sliver of a supermatter crystal. Do not handle without protection!"
	icon_state = "supermatter_sliver"
	pulseicon = "supermatter_sliver_pulse"
	w_class = WEIGHT_CLASS_BULKY //can't put it into bags
	layer = ABOVE_MOB_LAYER + 0.02
	radioactive_material = FALSE

/obj/item/nuke_core/supermatter_sliver/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/high_value_item)

/obj/item/nuke_core/supermatter_sliver/process()
	. = ..()
	var/new_filter = isnull(get_filter("ray"))
	ray_filter_helper(1, 40,"#ffd04f", 6, 20)
	if(new_filter)
		animate(get_filter("ray"), offset = 10, time = 10 SECONDS, loop = -1)
		animate(offset = 0, time = 10 SECONDS)

/obj/item/nuke_core/supermatter_sliver/attack_tk(mob/user) // no TK dusting memes
	return

/obj/item/nuke_core/supermatter_sliver/can_be_pulled(mob/user) // no drag memes
	if(HAS_TRAIT(user, TRAIT_SUPERMATTER_IMMUNE))
		return TRUE
	return FALSE

/obj/item/nuke_core/supermatter_sliver/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/retractor/supermatter))
		var/obj/item/retractor/supermatter/tongs = used
		if(tongs.sliver)
			to_chat(user, "<span class='warning'>[tongs] are already holding a supermatter sliver!</span>")
			return ITEM_INTERACT_COMPLETE

		forceMove(tongs)
		tongs.sliver = src
		tongs.update_icon(UPDATE_ICON_STATE)
		to_chat(user, "<span class='notice'>You carefully pick up [src] with [tongs].</span>")
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/scalpel/supermatter) || istype(used, /obj/item/nuke_core_container/supermatter)) // we don't want it to dust
		return ITEM_INTERACT_COMPLETE

	if(user.status_flags & GODMODE || HAS_TRAIT(user, TRAIT_SUPERMATTER_IMMUNE))
		return ITEM_INTERACT_COMPLETE

	if(issilicon(user))
		to_chat(user, "<span class='userdanger'>You try to touch [src] with [used]. ERROR!</span>")
		radiation_pulse(user, 2000, GAMMA_RAD)
		playsound(src, 'sound/effects/supermatter.ogg', 50, TRUE)
		user.dust()
		qdel(src)
		return ITEM_INTERACT_COMPLETE

	// Don't poke it with no-drops!
	if(!user.drop_item())
		radiation_pulse(user, 2000, GAMMA_RAD)
		to_chat(user, "<span class='userdanger'>As it touches [src], both [src] and [used] burst into dust. The resonance then consumes you as well!</span>")
		user.dust()
	else
		to_chat(user, "<span class='danger'>As it touches [src], both [src] and [used] burst into dust!</span>")
		radiation_pulse(user, 400, GAMMA_RAD)
		qdel(used)
	playsound(src, 'sound/effects/supermatter.ogg', 50, TRUE)
	qdel(src)
	return ITEM_INTERACT_COMPLETE

/obj/item/nuke_core/supermatter_sliver/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!isliving(hit_atom))
		return ..()

	var/mob/living/victim = hit_atom
	if(victim.incorporeal_move || victim.status_flags & GODMODE || HAS_TRAIT(victim, TRAIT_SUPERMATTER_IMMUNE)) //try to keep this in sync with supermatter's consume fail conditions
		return ..()

	var/mob/user = throwingdatum?.get_thrower()
	if(user)
		add_attack_logs(user, victim, "[victim] consumed by [src] thrown by [user] ")
		message_admins("[src] has consumed [key_name_admin(victim)] [ADMIN_JMP(src)], thrown by [key_name_admin(user)].")
		investigate_log("has consumed [key_name(victim)], thrown by [key_name(user)]", INVESTIGATE_SUPERMATTER)
	else
		message_admins("[src] has consumed [key_name_admin(victim)] [ADMIN_JMP(src)] via throw impact.")
		investigate_log("has consumed [key_name(victim)] via throw impact.", INVESTIGATE_SUPERMATTER)
	victim.visible_message("<span class='danger'>As [victim] is hit by [src], both flash into dust and silence fills the room...</span>",
		"<span class='userdanger'>You're hit by [src] and everything suddenly goes silent.\n[src] flashes into dust, and soon as you can register this, you do as well.</span>",
		"<span class='hear'>Everything suddenly goes silent.</span>")
	victim.dust()
	radiation_pulse(src, 2000, GAMMA_RAD)
	playsound(src, 'sound/effects/supermatter.ogg', 50, TRUE)
	qdel(src)

/obj/item/nuke_core/supermatter_sliver/pickup(mob/living/user)
	..()
	if(HAS_TRAIT(user, TRAIT_SUPERMATTER_IMMUNE))
		return TRUE //yay sliver throwing memes!

	if(!isliving(user) || user.status_flags & GODMODE) //try to keep this in sync with supermatter's consume fail conditions
		return FALSE

	user.visible_message("<span class='danger'>[user] reaches out and tries to pick up [src]. [user.p_their()] body starts to glow and bursts into flames before flashing into dust!</span>",
			"<span class='userdanger'>You reach for [src] with your hands. That was dumb.</span>",
			"<span class='hear'>Everything suddenly goes silent.</span>")
	radiation_pulse(user, 2000, GAMMA_RAD)
	playsound(src, 'sound/effects/supermatter.ogg', 50, TRUE)
	user.dust()

/obj/item/nuke_core_container/supermatter
	name = "supermatter bin"
	desc = "A modified Syndicate nuclear core receptacle, reinforced with a hyper-nobilium alloy lattice to permit the storage of Supermatter crystal shards."
	var/obj/item/nuke_core/supermatter_sliver/sliver

/obj/item/nuke_core_container/supermatter/Destroy()
	QDEL_NULL(sliver)
	return ..()

/obj/item/nuke_core_container/supermatter/load(obj/item/retractor/supermatter/I, mob/user)
	if(!istype(I) || !I.sliver || sliver)
		return

	I.sliver.forceMove(src)
	sliver = I.sliver
	I.sliver = null
	I.update_icon(UPDATE_ICON_STATE)
	icon_state = "supermatter_container_loaded"
	to_chat(user, "<span class='warning'>Container is sealing...</span>")
	addtimer(CALLBACK(src, PROC_REF(seal)), 10 SECONDS)


/obj/item/nuke_core_container/supermatter/seal()
	if(!QDELETED(sliver))
		STOP_PROCESSING(SSobj, sliver)
		var/datum/component/radioactive/contamination = GetComponent(/datum/component/radioactive)
		if(contamination)
			contamination.RemoveComponent()
		icon_state = "supermatter_container_sealed"
		playsound(src, 'sound/items/deconstruct.ogg', 60, TRUE)
		if(ismob(loc))
			to_chat(loc, "<span class='warning'>[src] is permanently sealed, [sliver] is safely contained.</span>")

/obj/item/nuke_core_container/supermatter/unload(obj/item/retractor/supermatter/I, mob/user)
	if(!istype(I) || I.sliver)
		return

	sliver.forceMove(I)
	I.sliver = sliver
	sliver = null
	I.update_icon(UPDATE_ICON_STATE)
	icon_state = "core_container_cracked_empty"
	to_chat(user, "<span class='notice'>You carefully pick up [I.sliver] with [I].</span>")

/obj/item/nuke_core_container/supermatter/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!istype(used, /obj/item/retractor/supermatter))
		return ..()

	var/obj/item/retractor/supermatter/tongs = used
	if(cracked)
		unload(tongs, user)
		return ITEM_INTERACT_COMPLETE

	load(tongs, user)
	return ITEM_INTERACT_COMPLETE

/obj/item/nuke_core_container/supermatter/attack_hand(mob/user)
	if(cracked && sliver) //What did we say about touching the shard...
		if(!isliving(user) || user.status_flags & GODMODE || HAS_TRAIT(user, TRAIT_SUPERMATTER_IMMUNE))
			return FALSE

		user.visible_message("<span class='danger'>[user] reaches out and tries to pick up [sliver]. [user.p_their()] body starts to glow and bursts into flames before flashing into dust!</span>",
				"<span class='userdanger'>You reach for [sliver] with your hands. That was dumb.</span>",
				"<span class='italics'>Everything suddenly goes silent.</span>")
		radiation_pulse(user, 2000, GAMMA_RAD)
		playsound(src, 'sound/effects/supermatter.ogg', 50, TRUE)
		message_admins("[sliver] has consumed [key_name_admin(user)] [ADMIN_JMP(src)].")
		investigate_log("has consumed [key_name(user)].", INVESTIGATE_SUPERMATTER)
		user.dust()
		icon_state = "core_container_cracked_empty"
		qdel(sliver)
	else
		return ..()

/obj/item/nuke_core_container/supermatter/crack_open()
	visible_message("<span class='boldnotice'>[src] bursts open!</span>")
	if(sliver)
		START_PROCESSING(SSobj, sliver)
		icon_state = "supermatter_container_cracked_loaded"
	else
		icon_state = "core_container_cracked_empty"
	name = "broken supermatter bin"
	cracked = TRUE

/obj/item/scalpel/supermatter
	name = "supermatter scalpel"
	desc = "A scalpel with a fragile tip of condensed hyper-noblium gas, searingly cold to the touch, that can safely shave a sliver off a supermatter crystal."
	icon = 'icons/obj/theft_tools.dmi'
	icon_state = "supermatter_scalpel"
	toolspeed = 0.5
	damtype = BURN
	usesound = 'sound/weapons/bladeslice.ogg'
	var/uses_left

/obj/item/scalpel/supermatter/Initialize(mapload)
	. = ..()
	uses_left = rand(2, 4)

/obj/item/retractor/supermatter
	name = "supermatter extraction tongs"
	desc = "A pair of tongs made from condensed hyper-noblium gas, searingly cold to the touch, that can safely grip a supermatter sliver."
	icon = 'icons/obj/theft_tools.dmi'
	icon_state = "supermatter_tongs"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	toolspeed = 0.75
	damtype = BURN
	var/obj/item/nuke_core/supermatter_sliver/sliver

/obj/item/retractor/supermatter/Destroy()
	QDEL_NULL(sliver)
	return ..()

/obj/item/retractor/supermatter/update_icon_state()
	icon_state = "[initial(icon_state)][sliver ? "_loaded" : ""]"

/obj/item/retractor/supermatter/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	. = ..()
	if(!sliver)
		return

	if(ismovable(target) && target != sliver)
		Consume(target, user)
		return ITEM_INTERACT_COMPLETE

/obj/item/retractor/supermatter/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum) // no instakill supermatter javelins
	if(sliver)
		sliver.forceMove(loc)
		visible_message("<span class='notice'>[sliver] falls out of [src] as it hits the ground.</span>")
		sliver = null
		update_icon(UPDATE_ICON_STATE)
	return ..()

/obj/item/retractor/supermatter/proc/Consume(atom/movable/AM, mob/living/user)
	if(istype(AM, /obj/item/nuke_core_container))
		return

	if(istype(AM, /obj/machinery/atmospherics/supermatter_crystal))
		return

	if(istype(AM, /obj/singularity))
		return

	if(ismob(AM))
		if(!isliving(AM))
			return

		var/mob/living/victim = AM
		if(victim.incorporeal_move || victim.status_flags & GODMODE || HAS_TRAIT(victim, TRAIT_SUPERMATTER_IMMUNE)) //try to keep this in sync with supermatter's consume fail conditions
			return

		victim.dust()
		radiation_pulse(src, 2000, GAMMA_RAD)
		message_admins("[src] has consumed [key_name_admin(victim)] [ADMIN_JMP(src)].")
		investigate_log("has irradiated [key_name(victim)].", INVESTIGATE_SUPERMATTER)

	playsound(src, 'sound/effects/supermatter.ogg', 50, TRUE)
	investigate_log("has consumed [AM].", INVESTIGATE_SUPERMATTER)
	qdel(AM)
	if(user)
		if(!(HAS_TRAIT(user, TRAIT_SUPERMATTER_IMMUNE) || user.status_flags & GODMODE))
			add_attack_logs(user, AM, "[AM] and [user] consumed by melee attack with [src] by [user].")
			user.visible_message(
				"<span class='danger'>As [user] touches [AM] with [src], both flash into dust and silence fills the room...</span>",
				"<span class='userdanger'>You touch [AM] with [src], and everything suddenly goes silent.\n[AM] and [sliver] flash into dust, and soon as you can register this, you do as well.</span>",
				"<span class='hear'>Everything suddenly goes silent.</span>"
			)
			user.dust()
			radiation_pulse(src, 2000, GAMMA_RAD)
		else
			add_attack_logs(user, AM, "[AM] consumed by melee attack with [src] by [user].")
			user.visible_message(
				"<span class='danger'>As [user] touches [AM] with [src], [AM] flashes into dust and silence fills the room...</span>",
				"<span class='userdanger'>You touch [AM] with [src], and everything suddenly goes silent.\n[AM] and [sliver] flash into dust.</span>",
				"<span class='hear'>Everything suddenly goes silent.</span>"
			)
	QDEL_NULL(sliver)
	update_icon(UPDATE_ICON_STATE)

// This device is used to analyze and trigger the particulate
/obj/item/ppp_processor
	name = "\improper Prototype Portable Particulate Processor"
	desc = "The Prototype Portable Particulate Processor, or PPPProcessor, for short, is a device designed to energize, collect, \
	and process anomalous particulate."
	icon = 'icons/obj/theft_tools.dmi'
	icon_state = "PPP_Processor_0"
	worn_icon_state = "gun"
	inhand_icon_state = "gun"
	lefthand_file = 'icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/guns_righthand.dmi'
	force = 10
	throwforce = 10
	attack_verb = list("processed", "perforated", "pounded", "pasted", "proded", "punished", "plowed into", "pommeled", "pummeled", "penetrated", "probed", "pulsed", "pulverized", "pillaged", "persecuted", "pasted", "peppered", "plundered", "put down", "pushed")
	origin_tech = "programming=6;plasma=6;syndicate=3"
	new_attack_chain = TRUE
	/// How many clouds have been processed?
	var/clouds_processed = 0
	/// Have we used it in hand to fully process the particulate and eject the canisters?
	var/fully_processed_particulate = FALSE
	/// Are we possibly processing particularly powerful packets?
	var/presently_processing_particular_particultate = FALSE
	/// The soundloop we use.
	var/datum/looping_sound/kitchen/microwave/me_cro_wah_vey

/obj/item/ppp_processor/Initialize(mapload)
	. = ..()
	me_cro_wah_vey = new /datum/looping_sound/kitchen/microwave(list(src), FALSE)

/obj/item/ppp_processor/Destroy()
	QDEL_NULL(me_cro_wah_vey)
	return ..()

/obj/item/ppp_processor/examine(mob/user)
	. = ..()
	if(fully_processed_particulate)
		. += "<span class='notice'>[src] has processed the data you now possess. All you need to do is present it after this shift.</span>"
		return
	if(clouds_processed < 3)
		. += "<span class='notice'>[src] has only [clouds_processed] out of 3 samples.</span>"
	if(clouds_processed == 3)
		. += "<span class='notice'>[src] has all 3 samples. Use it in hand to process the particulate.</span>"


/obj/item/ppp_processor/activate_self(mob/user)
	if(..())
		return
	if(fully_processed_particulate)
		to_chat(user, "<span class='notice'>[src] has already processed and ejected the particulate canisters. Just make sure to escape with the processor!</span>")
		return
	if(clouds_processed < 3)
		to_chat(user, "<span class='warning'>[src] has only [clouds_processed] out of 3 samples. You still need to collect more!</span>")
		return
	if(presently_processing_particular_particultate)
		to_chat(user, "<span class='warning'>[src] is presently processing particularly powerful packets of your particular particulate. Wait for it to finish before proceeding.</span>")
		return

	to_chat(user, "<span class='notice'>[src] is presently processing the particulate. Please hold as processing finishes, and be aware it may eject collection canisters.</span>")
	if(me_cro_wah_vey)
		me_cro_wah_vey.start()
	addtimer(CALLBACK(src, PROC_REF(perfectly_processed), user), 15 SECONDS)
	presently_processing_particular_particultate = TRUE

/obj/item/ppp_processor/update_icon_state()
	. = ..()
	switch(clouds_processed)
		if(-1)
			icon_state = "PPP_Processor_-1"
		if(0)
			icon_state = "PPP_Processor_0"
		if(1)
			icon_state = "PPP_Processor_1"
		if(2)
			icon_state = "PPP_Processor_2"
		if(3)
			icon_state = "PPP_Processor_3"

/obj/item/ppp_processor/proc/collect()
	clouds_processed++
	update_icon()

/obj/item/ppp_processor/proc/perfectly_processed(mob/user)
	if(!QDELETED(user))
		to_chat(user, "<span class='notice'>[src] has perfectly processed the particulate. You may now use the canisters however you wish. Ensure the processor gets back to us.</span>")
	me_cro_wah_vey.stop()
	presently_processing_particular_particultate = FALSE
	clouds_processed = -1
	fully_processed_particulate = TRUE
	update_icon()
	var/list/potential_grenade_rewards = list()
	potential_grenade_rewards += subtypesof(/obj/item/grenade/anomalous_canister)
	potential_grenade_rewards += /obj/item/grenade/anomalous_canister
	potential_grenade_rewards += /obj/effect/abstract/dummy_mini_spawner
	potential_grenade_rewards -= /obj/item/grenade/anomalous_canister/mini

	var/turf/our_turf = get_turf(src)
	our_turf.visible_message("<span class='warning'>Three containers are ejected out of [src].</span>")
	for(var/i in 1 to 3)
		var/obj/item/new_toy = pick_n_take(potential_grenade_rewards)
		new new_toy(get_turf(src))

/obj/item/clothing/glasses/hud/anomalous
	name = "anomalous particulate scanner HUD"
	desc = "A heads-up display that scans for anomalous particulate. Has a built in chameleon function, to help it blend in."
	icon_state = "sunhudmed"
	inhand_icon_state = "sunglasses"
	hud_types = DATA_HUD_ANOMALOUS

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
	desc = "This canister contains a cloud of charged anomalous particulate. It can be armed to create a temporary anomaly. \
	Be careful, with a glass exterior, it may shatter early when thrown."
	icon_state = "anomalous_canister"
	inhand_icon_state = "emp"
	origin_tech = "magnets=6;combat=6;syndicate=2"
	/// The type of anomaly the canister will spawn.
	var/obj/effect/anomaly/anomaly_type
	/// The lifetime of the anomaly.
	var/anomaly_lifetime = 45 SECONDS
	/// How many anomalies the grenade will spawn
	var/number_of_anomalies = 1
	/// Have we primed? It contains a cloud of particulate matter. Breaking it is going to let the anomaly out.
	var/has_primed = FALSE
	/// Chance to be a varient that the glass will shatter when thrown earlier than expected. The smaller canisters are more metal spheres, and will not.
	var/shatter_chance = 20

/obj/item/grenade/anomalous_canister/Initialize(mapload)
	. = ..()
	anomaly_type = pick(subtypesof(/obj/effect/anomaly))
	if(prob(shatter_chance))
		AddElement(/datum/element/shatters_when_thrown, /obj/effect/decal/cleanable/glass, 1, "shatter")

/obj/item/grenade/anomalous_canister/Destroy()
	prime()
	return ..()

/obj/item/grenade/anomalous_canister/prime()
	if(has_primed)
		return
	has_primed = TRUE
	var/turf/our_turf = get_turf(src)
	our_turf.visible_message("<span class='danger'>[src] shatters open, the [(number_of_anomalies - 1) ? "clouds" : "cloud"] of particulate rapidly forming into something more!</span>")
	playsound(src, "shatter", 70, TRUE)
	update_mob()
	for(var/i in 1 to number_of_anomalies)
		var/obj/effect/anomaly/A = new anomaly_type(our_turf, anomaly_lifetime, FALSE)
		A.anomalous_canister_setup()
	if(!QDELETED(src))
		qdel(src)

/obj/item/grenade/anomalous_canister/dual_core
	name = "dual clouded anomalous particulate canister"
	icon_state = "anomalous_canister_dual"
	number_of_anomalies = 2
	anomaly_lifetime = 30 SECONDS

/obj/item/grenade/anomalous_canister/dual_core/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Two smaller clouds of particulate are swirling around in this canister. It will likely form into two anomalies.</span>"

/obj/item/grenade/anomalous_canister/condensed
	name = "condensed anomalous particulate canister"
	icon_state = "anomalous_canister_condensed"
	anomaly_lifetime = 90 SECONDS

/obj/item/grenade/anomalous_canister/condensed/examine(mob/user)
	. = ..()
	. += "<span class='notice'>A large cloud of resiliant particulate is floating in this canister. It will last longer than other anomalies.</span>"

/obj/item/grenade/anomalous_canister/stabilized
	name = "stabilized anomalous particulate canister"
	desc = "The cloud of this particulate has stabilized enough for the computer to predict the anomaly it will condense into..."
	icon_state = "anomalous_canister_stable"

/obj/item/grenade/anomalous_canister/stabilized/examine(mob/user)
	. = ..()
	. += "<span class='notice'>The predicted result for the cloud to condense into is displayed as \an [anomaly_type::name]!</span>"

/obj/effect/abstract/dummy_mini_spawner

/obj/effect/abstract/dummy_mini_spawner/Initialize(mapload)
	. = ..()
	var/turf/our_turf = get_turf(src)
	our_turf.visible_message("<span class='warning'>One of the containers splits into 3 smaller capsules!</span>")
	for(var/i in 1 to 3)
		new /obj/item/grenade/anomalous_canister/mini(our_turf)
	return INITIALIZE_HINT_QDEL

/obj/item/grenade/anomalous_canister/mini
	name = "miniature anomalous particulate canister"
	desc = "This small sphere contains a small cloud of particulate. Likely won't form an anomally, but should still have a noticable impact"
	icon_state = "anomalous_canister_mini"
	w_class = 1
	shatter_chance = 0

/obj/item/grenade/anomalous_canister/mini/prime()
	if(has_primed)
		return
	has_primed = TRUE
	update_mob()
	var/turf/our_turf = get_turf(src)
	our_turf.visible_message("<span class='danger'>[src] activates and...</span>")
	playsound(src, "shatter", 70, TRUE)
	switch(anomaly_type)
		if(/obj/effect/anomaly/bluespace) // Teleport and slow combat for 15
			if(!is_teleport_allowed(z))
				visible_message("<span class='warning'>[src]'s fragments begin rapidly vibrating and blink out of existence.</span>")
				qdel(src)
				return
			for(var/mob/living/L in range(7, our_turf))
				do_teleport(L, get_turf(L), 7, sound_in = 'sound/effects/phasein.ogg')
				L.apply_status_effect(STATUS_EFFECT_BLUESPACESLOWDOWN)
		if(/obj/effect/anomaly/flux) // shock
			for(var/mob/living/L in view(7, our_turf))
				L.Beam(get_turf(src), icon_state = "lightning[rand(1, 12)]", icon = 'icons/effects/effects.dmi', time = 5) // What? Why are we beaming from the mob to the turf? Turf to mob generates really odd results.
				L.electrocute_act(20, "electrical blast", flags = SHOCK_NOGLOVES)
				L.KnockDown(6 SECONDS)
		if(/obj/effect/anomaly/grav) // repulse
			var/list/thrownatoms = list()
			var/atom/throwtarget
			var/distfromcaster
			for(var/turf/T in range(7, our_turf)) // Done this way so things don't get thrown all around hilariously.
				for(var/atom/movable/AM in T)
					thrownatoms += AM

			for(var/am in thrownatoms)
				var/atom/movable/AM = am
				if(AM == src || AM.anchored || AM.move_resist == INFINITY)
					continue

				throwtarget = get_edge_target_turf(src, get_dir(src, get_step_away(AM, src)))
				distfromcaster = get_dist(src, AM)
				if(distfromcaster == 0)
					if(isliving(AM))
						var/mob/living/M = AM
						M.Weaken(8 SECONDS)
						M.adjustBruteLoss(5)
						to_chat(M, "<span class='userdanger'>You're slammed into the floor by an anomalous force!</span>")
				else
					new /obj/effect/temp_visual/gravpush(get_turf(AM), get_dir(src, AM)) // created sparkles will disappear on their own
					if(isliving(AM))
						var/mob/living/M = AM
						M.Weaken(3 SECONDS)
						to_chat(M, "<span class='userdanger'>You're thrown back by a anomalous force!</span>")
					spawn(0)
						AM.throw_at(throwtarget, ((clamp((5 - (clamp(distfromcaster - 2, 0, distfromcaster))), 3, 5))), 1) // So stuff gets tossed around at the same time.
		if(/obj/effect/anomaly/pyro) // burn
			var/datum/gas_mixture/air = new()
			air.set_temperature(1000)
			air.set_toxins(20)
			air.set_oxygen(20)
			our_turf.blind_release_air(air)
			for(var/mob/living/L in view(7, our_turf))
				L.adjust_fire_stacks(6)
				L.IgniteMob()
		if(/obj/effect/anomaly/cryo) // weaker anomaly grenade
			for(var/turf/simulated/floor/T in view(4, our_turf))
				T.MakeSlippery(TURF_WET_ICE)
				for(var/mob/living/carbon/C in T)
					C.adjust_bodytemperature(-230)
					C.apply_status_effect(/datum/status_effect/freon)
		if(/obj/effect/anomaly/bhole) // big smoke that doesn't last as long as a smoke grenade
			var/datum/effect_system/smoke_spread/smoke
			smoke = new /datum/effect_system/smoke_spread/bad()
			smoke.set_up(20, FALSE, src)
			playsound(our_turf, 'sound/effects/smoke.ogg', 50, TRUE, -3)
			smoke.start()
	if(!QDELETED(src))
		qdel(src)

/obj/item/paper/guides/antag/anomalous_particulate
	name = "Particulate gathering instructions"
	info = {"<b>Instructions on your new PPPProcessor and HUD</b><br>
	<br>
	First off, equip your glasses. You will need them to find the particulate. We heavily advise against losing them.<br>
	<br>
	This will allow you to identify the uncharged anomalous particulate aboard the station. It can be anywhere, stalk out rooms and or use cameras to find it.\
	It will look like <b>purple sparkles, with a yellow and red square targeting highlight.</b><br>
	<br>
	Afterwords, approach the particulate with the PPPProcessor, and use it on the particulate. It will charge and capture a sample of it.<br>
	<br>
	<b>Warning:</b> Charged particulate is dangerous. Wear the goggles and leave the area. Try not to get caught in doing so.<br>
	<br>
	After collecting 3 diffrent unique samples (We will not accept a sample another agent has collected), use the scanner in hand to begin processing the particulate.<br>
	<br>
	After a short processing period, processing will be complete and you can bring the processor back to us. Additionally, 3 collection cansiters should eject.<br>
	<br>
	Feel free to use the canisters however you wish, they should be effective weapons, though do write down the results for us.
	<br><hr>
	<font size =\"1\"><i>We are not liable for any health conditions you may recive from scanning particulate or using the canisters.</i></font>
"}

