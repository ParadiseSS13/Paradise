/obj/item/clothing/mask/muzzle
	name = "muzzle"
	desc = "To stop that awful noise."
	icon_state = "muzzle"
	item_state = "muzzle"
	flags_cover = MASKCOVERSMOUTH
	w_class = WEIGHT_CLASS_SMALL
	gas_transfer_coefficient = 0.90
	put_on_delay = 20
	var/resist_time = 0 //deciseconds of how long you need to gnaw to get rid of the gag, 0 to make it impossible to remove
	var/mute = MUZZLE_MUTE_ALL
	var/security_lock = FALSE // Requires brig access to remove 0 - Remove as normal
	var/locked = FALSE //Indicates if a mask is locked, should always start as 0.

	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/mask.dmi'
		)

// Clumsy folks can't take the mask off themselves.
/obj/item/clothing/mask/muzzle/attack_hand(mob/user as mob)
	if(user.wear_mask == src && !user.IsAdvancedToolUser())
		return 0
	else if(security_lock && locked)
		if(do_unlock(user))
			visible_message("<span class='danger'>[user] unlocks [user.p_their()] [src.name].</span>", \
								"<span class='userdanger'>[user] unlocks [user.p_their()] [src.name].</span>")
	..()
	return 1

/obj/item/clothing/mask/muzzle/proc/do_break()
	if(security_lock)
		security_lock = FALSE
		locked = FALSE
		flags &= ~NODROP
		desc += " This one appears to be broken."
		return TRUE
	else
		return FALSE

/obj/item/clothing/mask/muzzle/proc/do_unlock(mob/living/carbon/human/user)
	if(istype(user.get_inactive_hand(), /obj/item/card/emag))
		to_chat(user, "<span class='warning'>The lock vibrates as the card forces its locking system open.</span>")
		do_break()
		return TRUE
	else if(ACCESS_BRIG in user.get_access())
		to_chat(user, "<span class='warning'>The muzzle unlocks with a click.</span>")
		locked = FALSE
		flags &= ~NODROP
		return TRUE

	to_chat(user, "<span class='warning'>You must be wearing a security ID card or have one in your inactive hand to remove the muzzle.</span>")
	return FALSE

/obj/item/clothing/mask/muzzle/proc/do_lock(mob/living/carbon/human/user)
	if(security_lock)
		locked = TRUE
		flags |= NODROP
		return TRUE
	return FALSE

/obj/item/clothing/mask/muzzle/Topic(href, href_list)
	..()
	if(href_list["locked"])
		var/mob/living/carbon/wearer = locate(href_list["locked"])
		var/success = 0
		if(ishuman(usr))
			visible_message("<span class='danger'>[usr] tries to [locked ? "unlock" : "lock"] [wearer]'s [name].</span>", \
							"<span class='userdanger'>[usr] tries to [locked ? "unlock" : "lock"] [wearer]'s [name].</span>")
			if(do_mob(usr, wearer, POCKET_STRIP_DELAY))
				if(locked)
					success = do_unlock(usr)
				else
					success = do_lock(usr)
			if(success)
				visible_message("<span class='danger'>[usr] [locked ? "locks" : "unlocks"] [wearer]'s [name].</span>", \
									"<span class='userdanger'>[usr] [locked ? "locks" : "unlocks"] [wearer]'s [name].</span>")
				if(usr.machine == wearer && in_range(src, usr))
					wearer.show_inv(usr)
		else
			to_chat(usr, "You lack the ability to manipulate the lock.")


/obj/item/clothing/mask/muzzle/tapegag
	name = "tape gag"
	desc = "MHPMHHH!"
	icon_state = "tapegag"
	item_state = null
	w_class = WEIGHT_CLASS_TINY
	resist_time = 150
	mute = MUZZLE_MUTE_MUFFLE
	flags = DROPDEL

	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/mask.dmi',
		"Unathi" = 'icons/mob/species/unathi/mask.dmi',
		"Tajaran" = 'icons/mob/species/tajaran/mask.dmi',
		"Vulpkanin" = 'icons/mob/species/vulpkanin/mask.dmi',
		"Grey" = 'icons/mob/species/grey/mask.dmi'
		)

/obj/item/clothing/mask/muzzle/tapegag/dropped(mob/user)
	var/obj/item/trash/tapetrash/TT = new
	transfer_fingerprints_to(TT)
	user.transfer_fingerprints_to(TT)
	user.put_in_active_hand(TT)
	playsound(src, 'sound/items/poster_ripped.ogg', 40, 1)
	user.emote("scream")
	..()

/obj/item/clothing/mask/muzzle/safety
	name = "safety muzzle"
	desc = "A muzzle designed to prevent biting."
	icon_state = "muzzle_secure"
	item_state = "muzzle_secure"
	resist_time = 0
	mute = MUZZLE_MUTE_NONE
	security_lock = TRUE
	locked = FALSE
	materials = list(MAT_METAL=500, MAT_GLASS=50)

	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/mask.dmi',
		"Unathi" = 'icons/mob/species/unathi/mask.dmi',
		"Tajaran" = 'icons/mob/species/tajaran/mask.dmi',
		"Vulpkanin" = 'icons/mob/species/vulpkanin/mask.dmi',
		"Grey" = 'icons/mob/species/grey/mask.dmi',
		"Drask" = 'icons/mob/species/drask/mask.dmi'
		)

/obj/item/clothing/mask/muzzle/safety/shock
	name = "shock muzzle"
	desc = "A muzzle designed to prevent biting.  This one is fitted with a behavior correction system."
	var/obj/item/assembly/trigger = null
	origin_tech = "materials=1;engineering=1"
	materials = list(MAT_METAL=500, MAT_GLASS=50)

/obj/item/clothing/mask/muzzle/safety/shock/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/assembly/signaler) || istype(W, /obj/item/assembly/voice))
		if(istype(trigger, /obj/item/assembly/signaler) || istype(trigger, /obj/item/assembly/voice))
			to_chat(user, "<span class='notice'>Something is already attached to [src].</span>")
			return FALSE
		if(!user.drop_item())
			to_chat(user, "<span class='warning'>You are unable to insert [W] into [src].</span>")
			return FALSE
		trigger = W
		trigger.forceMove(src)
		trigger.master = src
		trigger.holder = src
		to_chat(user, "<span class='notice'>You attach the [W] to [src].</span>")
		return TRUE
	else if(istype(W, /obj/item/assembly))
		to_chat(user, "<span class='notice'>That won't fit in [src]. Perhaps a signaler or voice analyzer would?</span>")
		return FALSE

	return ..()

/obj/item/clothing/mask/muzzle/safety/shock/screwdriver_act(mob/user, obj/item/I)
	if(!trigger)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	to_chat(user, "<span class='notice'>You remove [trigger] from [src].</span>")
	trigger.forceMove(get_turf(user))
	trigger.master = null
	trigger.holder = null
	trigger = null

/obj/item/clothing/mask/muzzle/safety/shock/proc/can_shock(obj/item/clothing/C)
	if(istype(C))
		if(isliving(C.loc))
			return C.loc
	else if(isliving(loc))
		return loc
	return FALSE

/obj/item/clothing/mask/muzzle/safety/shock/proc/process_activation(var/obj/D, var/normal = 1, var/special = 1)
	visible_message("[bicon(src)] *beep* *beep*", "*beep* *beep*")
	var/mob/M = can_shock(loc)
	if(M)
		to_chat(M, "<span class='danger'>You feel a sharp shock!</span>")
		do_sparks(3, 1, M)

		M.Weaken(5)
		M.Stuttering(1)
		M.Jitter(20)
	return

/obj/item/clothing/mask/muzzle/safety/shock/HasProximity(atom/movable/AM as mob|obj)
	if(trigger)
		trigger.HasProximity(AM)


/obj/item/clothing/mask/muzzle/safety/shock/hear_talk(mob/living/M as mob, list/message_pieces)
	if(trigger)
		trigger.hear_talk(M, message_pieces)

/obj/item/clothing/mask/muzzle/safety/shock/hear_message(mob/living/M as mob, msg)
	if(trigger)
		trigger.hear_message(M, msg)



/obj/item/clothing/mask/surgical
	name = "sterile mask"
	desc = "A sterile mask designed to help prevent the spread of diseases."
	icon_state = "sterile"
	item_state = "sterile"
	w_class = WEIGHT_CLASS_TINY
	flags_cover = MASKCOVERSMOUTH
	gas_transfer_coefficient = 0.90
	permeability_coefficient = 0.01
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 25, "rad" = 0, "fire" = 0, "acid" = 0)
	actions_types = list(/datum/action/item_action/adjust)

	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/mask.dmi',
		"Unathi" = 'icons/mob/species/unathi/mask.dmi',
		"Tajaran" = 'icons/mob/species/tajaran/mask.dmi',
		"Vulpkanin" = 'icons/mob/species/vulpkanin/mask.dmi',
		"Grey" = 'icons/mob/species/grey/mask.dmi',
		"Drask" = 'icons/mob/species/drask/mask.dmi'
		)


/obj/item/clothing/mask/surgical/attack_self(var/mob/user)
	adjustmask(user)

/obj/item/clothing/mask/fakemoustache
	name = "completely real moustache"
	desc = "moustache is totally real."
	icon_state = "fake-moustache"
	flags_inv = HIDEFACE
	actions_types = list(/datum/action/item_action/pontificate)
	dog_fashion = /datum/dog_fashion/head/not_ian

	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/mask.dmi',
		"Unathi" = 'icons/mob/species/unathi/mask.dmi',
		"Tajaran" = 'icons/mob/species/tajaran/mask.dmi',
		"Vulpkanin" = 'icons/mob/species/vulpkanin/mask.dmi',
		"Grey" = 'icons/mob/species/grey/mask.dmi',
		"Drask" = 'icons/mob/species/drask/mask.dmi'
		)

/obj/item/clothing/mask/fakemoustache/attack_self(mob/user)
	pontificate(user)

/obj/item/clothing/mask/fakemoustache/item_action_slot_check(slot)
	if(slot == slot_wear_mask)
		return 1

/obj/item/clothing/mask/fakemoustache/proc/pontificate(mob/user)
	user.visible_message("<span class='danger'>\ [user] twirls [user.p_their()] moustache and laughs [pick("fiendishly","maniacally","diabolically","evilly")]!</span>")

//scarves (fit in in mask slot)

/obj/item/clothing/mask/bluescarf
	name = "blue neck scarf"
	desc = "A blue neck scarf."
	icon_state = "blueneckscarf"
	item_state = "blueneckscarf"
	flags_cover = MASKCOVERSMOUTH
	w_class = WEIGHT_CLASS_SMALL
	gas_transfer_coefficient = 0.90


/obj/item/clothing/mask/redscarf
	name = "red scarf"
	desc = "A red and white checkered neck scarf."
	icon_state = "redwhite_scarf"
	item_state = "redwhite_scarf"
	flags_cover = MASKCOVERSMOUTH
	w_class = WEIGHT_CLASS_SMALL
	gas_transfer_coefficient = 0.90

/obj/item/clothing/mask/greenscarf
	name = "green scarf"
	desc = "A green neck scarf."
	icon_state = "green_scarf"
	item_state = "green_scarf"
	flags_cover = MASKCOVERSMOUTH
	w_class = WEIGHT_CLASS_SMALL
	gas_transfer_coefficient = 0.90

/obj/item/clothing/mask/ninjascarf
	name = "ninja scarf"
	desc = "A stealthy, dark scarf."
	icon_state = "ninja_scarf"
	item_state = "ninja_scarf"
	flags_cover = MASKCOVERSMOUTH
	w_class = WEIGHT_CLASS_SMALL
	gas_transfer_coefficient = 0.90


/obj/item/clothing/mask/pig
	name = "pig mask"
	desc = "A rubber pig mask."
	icon_state = "pig"
	item_state = "pig"
	flags = BLOCKHAIR
	flags_inv = HIDEFACE
	w_class = WEIGHT_CLASS_SMALL


/obj/item/clothing/mask/horsehead
	name = "horse head mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a horse."
	icon_state = "horsehead"
	item_state = "horsehead"
	flags = BLOCKHAIR
	flags_inv = HIDEFACE
	w_class = WEIGHT_CLASS_SMALL
	var/voicechange = 0
	var/temporaryname = " the Horse"
	var/originalname = ""

	sprite_sheets = list(
		"Grey" = 'icons/mob/species/grey/mask.dmi',
		"Drask" = 'icons/mob/species/drask/mask.dmi'
	)

/obj/item/clothing/mask/horsehead/equipped(mob/user, slot)
	if(flags & NODROP)	//cursed masks only
		originalname = user.real_name
		if(!user.real_name || user.real_name == "Unknown")
			user.real_name = "A Horse With No Name" //it felt good to be out of the rain
		else
			user.real_name = "[user.name][temporaryname]"
		..()

/obj/item/clothing/mask/horsehead/dropped() //this really shouldn't happen, but call it extreme caution
	if(flags & NODROP)
		goodbye_horses(loc)
	..()

/obj/item/clothing/mask/horsehead/Destroy()
	if(flags & NODROP)
		goodbye_horses(loc)
	return ..()

/obj/item/clothing/mask/horsehead/proc/goodbye_horses(mob/user) //I'm flying over you
	if(!ismob(user))
		return
	if(user.real_name == "[originalname][temporaryname]" || user.real_name == "A Horse With No Name") //if it's somehow changed while the mask is on it doesn't revert
		user.real_name = originalname

/obj/item/clothing/mask/face
	flags_inv = HIDEFACE
	flags_cover = MASKCOVERSMOUTH

/obj/item/clothing/mask/face/rat
	name = "rat mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a rat."
	icon_state = "rat"
	item_state = "rat"

/obj/item/clothing/mask/face/fox
	name = "fox mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a fox."
	icon_state = "fox"
	item_state = "fox"

/obj/item/clothing/mask/face/bee
	name = "bee mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a bee."
	icon_state = "bee"
	item_state = "bee"

/obj/item/clothing/mask/face/bear
	name = "bear mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a bear."
	icon_state = "bear"
	item_state = "bear"

/obj/item/clothing/mask/face/bat
	name = "bat mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a bat."
	icon_state = "bat"
	item_state = "bat"

/obj/item/clothing/mask/face/raven
	name = "raven mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a raven."
	icon_state = "raven"
	item_state = "raven"

/obj/item/clothing/mask/face/jackal
	name = "jackal mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a jackal."
	icon_state = "jackal"
	item_state = "jackal"

/obj/item/clothing/mask/face/tribal
	name = "tribal mask"
	desc = "A mask carved out of wood, detailed carefully by hand."
	icon_state = "bumba"
	item_state = "bumba"

/obj/item/clothing/mask/fawkes
	name = "Guy Fawkes mask"
	desc = "A mask designed to help you remember a specific date."
	icon_state = "fawkes"
	item_state = "fawkes"
	flags_inv = HIDEFACE
	w_class = WEIGHT_CLASS_SMALL

/obj/item/clothing/mask/gas/clown_hat/pennywise
	name = "Pennywise Mask"
	desc = "It's the eater of worlds, and of children."
	icon_state = "pennywise_mask"
	item_state = "pennywise_mask"

	flags = BLOCK_GAS_SMOKE_EFFECT | AIRTIGHT | BLOCKHAIR

// Bandanas
/obj/item/clothing/mask/bandana
	name = "bandana"
	desc = "A colorful bandana."
	flags_inv = HIDEFACE
	flags_cover = MASKCOVERSMOUTH
	w_class = WEIGHT_CLASS_TINY
	slot_flags = SLOT_MASK
	adjusted_flags = SLOT_HEAD
	icon_state = "bandbotany"

	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/mask.dmi',
		"Unathi" = 'icons/mob/species/unathi/mask.dmi',
		"Tajaran" = 'icons/mob/species/tajaran/mask.dmi',
		"Vulpkanin" = 'icons/mob/species/vulpkanin/mask.dmi',
		"Grey" = 'icons/mob/species/grey/mask.dmi',
		"Drask" = 'icons/mob/species/drask/mask.dmi'
		)
	actions_types = list(/datum/action/item_action/adjust)

/obj/item/clothing/mask/bandana/attack_self(var/mob/user)
	adjustmask(user)

/obj/item/clothing/mask/bandana/red
	name = "red bandana"
	icon_state = "bandred"
	item_color = "red"
	desc = "It's a red bandana."

/obj/item/clothing/mask/bandana/blue
	name = "blue bandana"
	icon_state = "bandblue"
	item_color = "blue"
	desc = "It's a blue bandana."

/obj/item/clothing/mask/bandana/gold
	name = "gold bandana"
	icon_state = "bandgold"
	item_color = "yellow"
	desc = "It's a gold bandana."

/obj/item/clothing/mask/bandana/green
	name = "green bandana"
	icon_state = "bandgreen"
	item_color = "green"
	desc = "It's a green bandana."

/obj/item/clothing/mask/bandana/orange
	name = "orange bandana"
	icon_state = "bandorange"
	item_color = "orange"
	desc = "It's an orange bandana."

/obj/item/clothing/mask/bandana/purple
	name = "purple bandana"
	icon_state = "bandpurple"
	item_color = "purple"
	desc = "It's a purple bandana."

/obj/item/clothing/mask/bandana/botany
	name = "botany bandana"
	desc = "It's a green bandana with some fine nanotech lining."
	icon_state = "bandbotany"

/obj/item/clothing/mask/bandana/skull
	name = "skull bandana"
	desc = "It's a black bandana with a skull pattern."
	icon_state = "bandskull"

/obj/item/clothing/mask/bandana/black
	name = "black bandana"
	icon_state = "bandblack"
	item_color = "black"
	desc = "It's a black bandana."

/obj/item/clothing/mask/bandana/durathread
	name = "durathread bandana"
	desc =  "A bandana made from durathread, you wish it would provide some protection to its wearer, but it's far too thin..."
	icon_state = "banddurathread"

/obj/item/clothing/mask/cursedclown
	name = "cursed clown mask"
	desc = "This is a very, very odd looking mask."
	icon = 'icons/goonstation/objects/clothing/mask.dmi'
	icon_state = "cursedclown"
	item_state = "cclown_hat"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	icon_override = 'icons/goonstation/mob/clothing/mask.dmi'
	lefthand_file = 'icons/goonstation/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/goonstation/mob/inhands/clothing_righthand.dmi'
	flags = NODROP | AIRTIGHT
	flags_cover = MASKCOVERSMOUTH

/obj/item/clothing/mask/cursedclown/equipped(mob/user, slot)
	..()
	var/mob/living/carbon/human/H = user
	if(istype(H) && slot == slot_wear_mask)
		to_chat(H, "<span class='danger'>[src] grips your face!</span>")
		if(H.mind && H.mind.assigned_role != "Cluwne")
			H.makeCluwne()

/obj/item/clothing/mask/cursedclown/suicide_act(mob/user)
	user.visible_message("<span class='danger'>[user] gazes into the eyes of [src]. [src] gazes back!</span>")
	spawn(10)
		if(user)
			user.gib()
	return OBLITERATION
