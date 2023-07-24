//Items for nuke theft, supermatter theft traitor objective


// STEALING THE NUKE

//the nuke core, base item
/obj/item/nuke_core
	name = "plutonium core"
	desc = "Extremely radioactive. Wear goggles."
	icon = 'icons/obj/nuke_tools.dmi'
	icon_state = "plutonium_core"
	item_state = "plutoniumcore"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	flags_2 = RAD_NO_CONTAMINATE_2 //Don't have the item itself become irradiated when it makes radiation.
	var/cooldown = 0
	var/pulseicon = "plutonium_core_pulse"

/obj/item/nuke_core/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/nuke_core/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/nuke_core/attackby(obj/item/nuke_core_container/container, mob/user)
	if(istype(container))
		container.load(src, user)
	else
		return ..()

/obj/item/nuke_core/process()
	if(cooldown < world.time - 6 SECONDS)
		cooldown = world.time
		flick(pulseicon, src)
		radiation_pulse(src, 400, 2)

/obj/item/nuke_core/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is rubbing [src] against [user.p_themselves()]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return TOXLOSS

/obj/item/nuke_core/plutonium //The steal objective, so it doesnt mess with the SM sliver on pinpointers and objectives

//nuke core box, for carrying the core
/obj/item/nuke_core_container
	name = "nuke core container"
	desc = "A solid container for radioactive objects."
	icon = 'icons/obj/nuke_tools.dmi'
	icon_state = "core_container_empty"
	item_state = "metal"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF //Don't want people trying to break it open with acid, then destroying the core.
	var/obj/item/nuke_core/plutonium/core
	var/dented = FALSE
	var/cracked = FALSE

/obj/item/nuke_core_container/Destroy()
	QDEL_NULL(core)
	return ..()

/obj/item/nuke_core_container/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			if(!cracked)
				crack_open()
		if(EXPLODE_HEAVY)
			if(!dented)
				dented = TRUE

/obj/item/nuke_core_container/examine(mob/user)
	. = ..()
	if(cracked) // Cracked open.
		. += "<span class='warning'>It is broken, and can no longer store objects safely.</span>"
	else if(dented) // Not cracked, but dented.
		. += "<span class='notice'>[src] looks dented. Perhaps a bigger explosion may break it.</span>"
	else // Not cracked or dented.
		. += "Fine print on the box reads \"Cybersun Industries secure container, guaranteed thermite proof, assistant proof, and explosive resistant.\""

/obj/item/nuke_core_container/attack_hand(mob/user)
	if(cracked && core)
		unload(user)
	else
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
		STOP_PROCESSING(SSobj, core)
		icon_state = "core_container_sealed"
		playsound(src, 'sound/items/deconstruct.ogg', 60, TRUE)
		if(ismob(loc))
			to_chat(loc, "<span class='warning'>[src] is permanently sealed, [core]'s radiation is contained.</span>")

/obj/item/nuke_core_container/attackby(obj/item/nuke_core/plutonium/core, mob/user)
	if(!istype(core) || cracked)
		return ..()

	if(!user.drop_item())
		to_chat(user, "<span class='warning'>[core] is stuck to your hand!</span>")
		return
	else
		load(core, user)

/obj/item/nuke_core_container/proc/crack_open()
	visible_message("<span class='boldnotice'>[src] bursts open!</span>")
	if(core)
		START_PROCESSING(SSobj, core)
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

// STEALING SUPERMATTER.

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
	layer = ABOVE_MOB_LAYER + 0.02

/obj/item/nuke_core/supermatter_sliver/process()
	. = ..()
	var/new_filter = isnull(get_filter("ray"))
	ray_filter_helper(1, 40,"#ffd04f", 6, 20)
	if(new_filter)
		animate(get_filter("ray"), offset = 10, time = 10 SECONDS, loop = -1)
		animate(offset = 0, time = 10 SECONDS)

/obj/item/nuke_core/supermatter_sliver/attack_tk(mob/user) // no TK dusting memes
	return

/obj/item/nuke_core/supermatter_sliver/can_be_pulled(user) // no drag memes
	return FALSE

/obj/item/nuke_core/supermatter_sliver/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/retractor/supermatter))
		var/obj/item/retractor/supermatter/tongs = I
		if(tongs.sliver)
			to_chat(user, "<span class='warning'>[tongs] are already holding a supermatter sliver!</span>")
			return FALSE
		forceMove(tongs)
		tongs.sliver = src
		tongs.icon_state = "supermatter_tongs_loaded"
		tongs.item_state = "supermatter_tongs_loaded"
		to_chat(user, "<span class='notice'>You carefully pick up [src] with [tongs].</span>")
	else if(istype(I, /obj/item/scalpel/supermatter) || istype(I, /obj/item/nuke_core_container/supermatter)) // we don't want it to dust
		return
	else
		if(issilicon(user))
			to_chat(user, "<span class='userdanger'>You try to touch [src] with one of your modules. Error!</span>")
			radiation_pulse(user, 500, 2)
			playsound(src, 'sound/effects/supermatter.ogg', 50, TRUE)
			user.dust()
			qdel(src)
			return
		to_chat(user, "<span class='danger'>As it touches [src], both [src] and [I] burst into dust!</span>")
		radiation_pulse(user, 100)
		playsound(src, 'sound/effects/supermatter.ogg', 50, TRUE)
		qdel(I)
		qdel(src)

/obj/item/nuke_core/supermatter_sliver/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!isliving(hit_atom))
		return ..()
	var/mob/living/victim = hit_atom
	if(victim.incorporeal_move || victim.status_flags & GODMODE) //try to keep this in sync with supermatter's consume fail conditions
		return ..()
	if(throwingdatum?.thrower)
		var/mob/user = throwingdatum.thrower
		add_attack_logs(user, victim, "[victim] consumed by [src] thrown by [user] ")
		message_admins("[src] has consumed [key_name_admin(victim)] [ADMIN_JMP(src)], thrown by [key_name_admin(user)].")
		investigate_log("has consumed [key_name(victim)], thrown by [key_name(user)]", "supermatter")
	else
		message_admins("[src] has consumed [key_name_admin(victim)] [ADMIN_JMP(src)] via throw impact.")
		investigate_log("has consumed [key_name(victim)] via throw impact.", "supermatter")
	victim.visible_message("<span class='danger'>As [victim] is hit by [src], both flash into dust and silence fills the room...</span>",
		"<span class='userdanger'>You're hit by [src] and everything suddenly goes silent.\n[src] flashes into dust, and soon as you can register this, you do as well.</span>",
		"<span class='hear'>Everything suddenly goes silent.</span>")
	victim.dust()
	radiation_pulse(src, 500, 2)
	playsound(src, 'sound/effects/supermatter.ogg', 50, TRUE)
	qdel(src)

/obj/item/nuke_core/supermatter_sliver/pickup(mob/living/user)
	..()
	if(!isliving(user) || user.status_flags & GODMODE) //try to keep this in sync with supermatter's consume fail conditions
		return FALSE
	user.visible_message("<span class='danger'>[user] reaches out and tries to pick up [src]. [user.p_their()] body starts to glow and bursts into flames before flashing into dust!</span>",
			"<span class='userdanger'>You reach for [src] with your hands. That was dumb.</span>",
			"<span class='hear'>Everything suddenly goes silent.</span>")
	radiation_pulse(user, 500, 2)
	playsound(src, 'sound/effects/supermatter.ogg', 50, TRUE)
	user.dust()

/obj/item/nuke_core_container/supermatter
	name = "supermatter bin"
	desc = "A tiny receptacle that releases an inert hyper-noblium mix upon sealing, allowing a sliver of a supermatter crystal to be safely stored."
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
	I.icon_state = "supermatter_tongs"
	I.item_state = "supermatter_tongs"
	icon_state = "supermatter_container_loaded"
	to_chat(user, "<span class='warning'>Container is sealing...</span>")
	addtimer(CALLBACK(src, PROC_REF(seal)), 10 SECONDS)

/obj/item/nuke_core_container/supermatter/seal()
	if(!QDELETED(sliver))
		STOP_PROCESSING(SSobj, sliver)
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
	I.icon_state = "supermatter_tongs_loaded"
	I.item_state = "supermatter_tongs_loaded"
	icon_state = "core_container_cracked_empty"
	to_chat(user, "<span class='notice'>You carefully pick up [I.sliver] with [I].</span>")

/obj/item/nuke_core_container/supermatter/attackby(obj/item/retractor/supermatter/tongs, mob/user)
	if(istype(tongs))
		if(cracked)
			//lets take that shard out
			unload(tongs, user)
		else
			//try to load shard into core
			load(tongs, user)
	else
		return ..()

/obj/item/nuke_core_container/supermatter/attack_hand(mob/user)
	if(cracked && sliver) //What did we say about touching the shard...
		if(!isliving(user) || user.status_flags & GODMODE)
			return FALSE
		user.visible_message("<span class='danger'>[user] reaches out and tries to pick up [sliver]. [user.p_their()] body starts to glow and bursts into flames before flashing into dust!</span>",
				"<span class='userdanger'>You reach for [sliver] with your hands. That was dumb.</span>",
				"<span class='italics'>Everything suddenly goes silent.</span>")
		radiation_pulse(user, 500, 2)
		playsound(src, 'sound/effects/supermatter.ogg', 50, TRUE)
		message_admins("[sliver] has consumed [key_name_admin(user)] [ADMIN_JMP(src)].")
		investigate_log("has consumed [key_name(user)].", "supermatter")
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
	icon = 'icons/obj/nuke_tools.dmi'
	icon_state = "supermatter_scalpel"
	toolspeed = 0.5
	damtype = BURN
	usesound = 'sound/weapons/bladeslice.ogg'
	var/uses_left

/obj/item/scalpel/supermatter/Initialize()
	. = ..()
	uses_left = rand(2, 4)

/obj/item/retractor/supermatter
	name = "supermatter extraction tongs"
	desc = "A pair of tongs made from condensed hyper-noblium gas, searingly cold to the touch, that can safely grip a supermatter sliver."
	icon = 'icons/obj/nuke_tools.dmi'
	icon_state = "supermatter_tongs"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	item_state = "supermatter_tongs"
	toolspeed = 0.75
	damtype = BURN
	var/obj/item/nuke_core/supermatter_sliver/sliver

/obj/item/retractor/supermatter/Destroy()
	QDEL_NULL(sliver)
	return ..()

/obj/item/retractor/supermatter/afterattack(atom/O, mob/user, proximity)
	. = ..()
	if(!sliver)
		return
	if(proximity && ismovable(O) && O != sliver)
		Consume(O, user)

/obj/item/retractor/supermatter/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum) // no instakill supermatter javelins
	if(sliver)
		sliver.forceMove(loc)
		visible_message("<span class='notice'>[sliver] falls out of [src] as it hits the ground.</span>")
		sliver = null
		icon_state = "supermatter_tongs"
		item_state = "supermatter_tongs"
	return ..()

/obj/item/retractor/supermatter/proc/Consume(atom/movable/AM, mob/living/user)
	if(ismob(AM))
		if(!isliving(AM))
			return
		var/mob/living/victim = AM
		if(victim.incorporeal_move || victim.status_flags & GODMODE) //try to keep this in sync with supermatter's consume fail conditions
			return
		victim.dust()
		message_admins("[src] has consumed [key_name_admin(victim)] [ADMIN_JMP(src)].")
		investigate_log("has irradiated [key_name(victim)].", "supermatter")
	else if(istype(AM, /obj/singularity))
		return
	else if(istype(AM, /obj/item/nuke_core_container))
		return
	else if(istype(AM, /obj/machinery/atmospherics/supermatter_crystal))
		return
	else
		investigate_log("has consumed [AM].", "supermatter")
		qdel(AM)

	if(user)
		add_attack_logs(user, AM, "[AM] and [user] consumed by melee attack with [src] by [user]")
		user.visible_message("<span class='danger'>As [user] touches [AM] with [src], both flash into dust and silence fills the room...</span>",
			"<span class='userdanger'>You touch [AM] with [src], and everything suddenly goes silent.\n[AM] and [sliver] flash into dust, and soon as you can register this, you do as well.</span>",
			"<span class='hear'>Everything suddenly goes silent.</span>")
		user.dust()
	radiation_pulse(src, 500, 2)
	playsound(src, 'sound/effects/supermatter.ogg', 50, TRUE)
	QDEL_NULL(sliver)
