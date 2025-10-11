/obj/item/wrench
	name = "wrench"
	desc = "A standard adjustable wrench made of forged steel. Can be used to fasten or remove bolts, and deconstruct objects."
	icon = 'icons/obj/tools.dmi'
	icon_state = "wrench"
	belt_icon = "wrench"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	force = 5
	throwforce = 7
	usesound = 'sound/items/ratchet.ogg'
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL = 600)
	drop_sound = 'sound/items/handling/wrench_drop.ogg'
	pickup_sound =  'sound/items/handling/wrench_pickup.ogg'
	origin_tech = "materials=1;engineering=1"
	attack_verb = list("bashed", "battered", "bludgeoned", "whacked")
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 50, ACID = 30)
	tool_behaviour = TOOL_WRENCH

	new_attack_chain = TRUE

/obj/item/wrench/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_BIT_ATTACH, PROC_REF(add_bit))
	RegisterSignal(src, COMSIG_CLICK_ALT, PROC_REF(remove_bit))

/obj/item/wrench/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is unsecuring [user.p_their()] head with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")

	if(!use_tool(user, user, 3 SECONDS, volume = tool_volume))
		return SHAME

	if(!ishuman(user))
		return BRUTELOSS

	var/mob/living/carbon/human/H = user
	var/obj/item/organ/external/head/head = H.bodyparts_by_name["head"]
	if(!head)
		user.visible_message("<span class='suicide'>...but [user.p_they()] [user.p_are()] already headless! How embarassing.</span>")
		return SHAME

	head.droplimb(TRUE, DROPLIMB_SHARP, FALSE, TRUE)

	if(user.stat != DEAD)
		user.visible_message("<span class='suicide'>...but [user.p_they()] didn't need it anyway! How embarassing.</span>")
		return SHAME

	return OXYLOSS

/obj/item/wrench/cyborg
	name = "automatic wrench"
	desc = "A powered industrial wrench commonly found in construction and engineering robots. More efficient than most manual wrenches."
	toolspeed = 0.5

/obj/item/wrench/brass
	name = "brass wrench"
	desc = "A brass adjustable wrench. It's faintly warm to the touch."
	icon_state = "wrench_brass"
	belt_icon = "wrench_brass"
	toolspeed = 0.5
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/wrench/power
	name = "hand drill"
	desc = "A powerful, hand-held drill fitted with a long-lasting battery. It has a bolt driver head attached."
	icon_state = "drill_bolt"
	inhand_icon_state = "drill"
	belt_icon = "hand_drill"
	usesound = 'sound/items/impactwrench.ogg' // Sourced from freesfx.co.uk
	materials = list(MAT_METAL=150,MAT_SILVER=50,MAT_TITANIUM=25)
	origin_tech = "materials=2;engineering=2"
	force = 8
	throwforce = 8
	attack_verb = list("drilled", "screwed", "jabbed")
	toolspeed = 0.25
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/wrench/power/activate_self(mob/user)
	if(..())
		return

	playsound(get_turf(user),'sound/items/change_drill.ogg', 50, 1)
	var/obj/item/wirecutters/power/s_drill = new /obj/item/screwdriver/power
	to_chat(user, "<span class='notice'>You attach the screwdriver bit to [src].</span>")
	for(var/obj/item/smithed_item/tool_bit/bit in attached_bits)
		bit.on_detached()
		bit.forceMove(s_drill)
		s_drill.attached_bits += bit
		bit.on_attached(s_drill)
	qdel(src)
	user.put_in_active_hand(s_drill)

/obj/item/wrench/power/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is pressing [src] against [user.p_their()] head! It looks like [user.p_theyre()] trying to commit suicide!")
	return BRUTELOSS

/obj/item/wrench/medical
	name = "medical wrench"
	desc = "A standard adjustable wrench covered in medical iconography. Its outer surface is mostly covered in rubber, and it seems to be more efficient than a normal wrench."
	icon_state = "wrench_medical"
	force = 2 //MEDICAL
	throwforce = 4
	origin_tech = "materials=1;engineering=1;biotech=3"
	attack_verb = list("wrenched", "medicaled", "tapped", "jabbed", "whacked")
	toolspeed = 0.75

/obj/item/wrench/medical/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] is praying to the medical wrench to take [user.p_their()] soul. It looks like [user.p_theyre()] trying to commit suicide!</span>")
	// HAVE THEM GLOW WITH THE BRIGHTNESS OF A THOUSAND SUNS
	user.set_light(10, 25, rgb(255, 252, 82))

	var/previous_color = user.color

	user.color = rgb(255, 252, 82)

	// thank you vi3
	user.add_filter("sacrifice_glow", 2, list("type" = "outline", "color" = "#55dcfdd2", "size" = 2))
	var/filter = user.get_filter("sacrifice_glow")
	// Pulse in and out
	animate(filter, alpha = 110, time = 3, loop = -1)
	animate(alpha = 40, time = 6)

	// Immobilize stops them from wandering off and dropping the wrench
	user.Immobilize(10 SECONDS)
	playsound(loc, 'sound/effects/pray.ogg', 50, TRUE, -1)

	// Let the sound effect finish playing
	sleep(20)

	if(!user)
		return

	for(var/obj/item/W in user)
		user.drop_item_to_ground(W)

	for(var/mob/living/M in orange(2, src))
		// you're close enough, it's pretty fuckin bright
		M.flash_eyes(1, TRUE, TRUE)

	var/obj/item/wrench/medical/W = new /obj/item/wrench/medical(loc)
	W.add_fingerprint(user)
	W.desc += " For some reason, it reminds you of [user.name]."

	if(!user)
		return

	user.color = previous_color  // for the sake of their ghost

	user.dust()
	user.visible_message("<span class='suicide'>[user]'s soul coalesces into a new [W.name]!</span>")
	return OBLITERATION

/obj/item/wrench/bolter
	name = "airlock bolt wrench"
	desc = "A large wrench designed to interlock with an airlock's bolting mechanisms, allowing it to lift the bolts regardless of power."
	icon_state = "bolter_wrench"
	origin_tech = "materials=5;engineering=4"
	w_class = WEIGHT_CLASS_NORMAL
	toolspeed = 2.5
