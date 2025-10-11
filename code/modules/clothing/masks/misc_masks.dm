/obj/item/clothing/mask/muzzle
	name = "muzzle"
	desc = "To stop that awful noise."
	icon_state = "muzzle"
	inhand_icon_state = "muzzle"
	flags_cover = MASKCOVERSMOUTH
	gas_transfer_coefficient = 0.90
	put_on_delay = 2 SECONDS
	/// How long you need to gnaw to get rid of the gag, 0 to make it impossible to remove
	var/resist_time = 0 SECONDS
	var/mute = MUZZLE_MUTE_ALL
	var/security_lock = FALSE // Requires brig access to remove 0 - Remove as normal
	var/locked = FALSE //Indicates if a mask is locked, should always start as 0.
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/mask.dmi'
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
		set_nodrop(FALSE, loc)
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
		set_nodrop(FALSE, loc)
		return TRUE

	to_chat(user, "<span class='warning'>You must be wearing a security ID card or have one in your inactive hand to remove the muzzle.</span>")
	return FALSE

/obj/item/clothing/mask/muzzle/proc/do_lock(mob/living/carbon/human/user)
	if(security_lock)
		locked = TRUE
		set_nodrop(TRUE, loc)
		return TRUE
	return FALSE

/obj/item/clothing/mask/muzzle/tapegag
	name = "tape gag"
	desc = "MHPMHHH!"
	icon_state = "tapegag"
	inhand_icon_state = null
	w_class = WEIGHT_CLASS_TINY
	resist_time = 30 SECONDS
	mute = MUZZLE_MUTE_MUFFLE
	flags = DROPDEL

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/mask.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/mask.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/mask.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/mask.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/mask.dmi'
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
	mute = MUZZLE_MUTE_NONE
	security_lock = TRUE
	materials = list(MAT_METAL=500, MAT_GLASS=50)

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/mask.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/mask.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/mask.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/mask.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/mask.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/mask.dmi'
		)

/obj/item/clothing/mask/muzzle/safety/shock
	name = "shock muzzle"
	desc = "A muzzle designed to prevent biting. This one is fitted with a behavior correction system."
	var/obj/item/assembly/trigger = null
	origin_tech = "materials=1;engineering=1"
	materials = list(MAT_METAL=500, MAT_GLASS=50)

/obj/item/clothing/mask/muzzle/safety/shock/attackby__legacy__attackchain(obj/item/W, mob/user, params)
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
		to_chat(user, "<span class='notice'>You attach [W] to [src].</span>")
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

/obj/item/clothing/mask/muzzle/safety/shock/proc/process_activation(obj/D, normal = 1, special = 1)
	var/mob/living/L = can_shock(loc)
	if(!L)
		return
	to_chat(L, "<span class='danger'>You feel a sharp shock!</span>")
	do_sparks(3, 1, L)

	L.Weaken(10 SECONDS)
	L.Stuttering(2 SECONDS)
	L.Jitter(40 SECONDS)


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
	inhand_icon_state = "m_mask"
	w_class = WEIGHT_CLASS_TINY
	flags_cover = MASKCOVERSMOUTH
	gas_transfer_coefficient = 0.90
	permeability_coefficient = 0.01
	actions_types = list(/datum/action/item_action/adjust)
	can_toggle = TRUE
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/mask.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/mask.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/mask.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/mask.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/mask.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/mask.dmi'
	)

/obj/item/clothing/mask/surgical/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_ANTI_VIRAL, "inherent")

/obj/item/clothing/mask/surgical/attack_self__legacy__attackchain(mob/user)
	adjustmask(user)

/obj/item/clothing/mask/fakemoustache
	name = "completely real moustache"
	desc = "moustache is totally real."
	icon_state = "fake-moustache"
	flags_inv = HIDEFACE
	actions_types = list(/datum/action/item_action/pontificate)
	dog_fashion = /datum/dog_fashion/head/not_ian

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/mask.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/mask.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/mask.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/mask.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/mask.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/mask.dmi'
		)

/obj/item/clothing/mask/fakemoustache/attack_self__legacy__attackchain(mob/user)
	pontificate(user)

/obj/item/clothing/mask/fakemoustache/item_action_slot_check(slot)
	if(slot == ITEM_SLOT_MASK)
		return 1

/obj/item/clothing/mask/fakemoustache/proc/pontificate(mob/user)
	user.visible_message("<span class='danger'>\ [user] twirls [user.p_their()] moustache and laughs [pick("fiendishly","maniacally","diabolically","evilly")]!</span>")

/obj/item/clothing/mask/pig
	name = "pig mask"
	desc = "A rubber pig mask."
	icon_state = "pig"
	flags = BLOCKHAIR
	flags_inv = HIDEFACE

/obj/item/clothing/mask/horsehead
	name = "horse head mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a horse."
	icon_state = "horsehead"
	flags = BLOCKHAIR
	flags_inv = HIDEFACE
	var/voicechange = FALSE
	var/temporaryname = " the Horse"
	var/originalname = ""

	sprite_sheets = list(
		"Grey" = 'icons/mob/clothing/species/grey/mask.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/mask.dmi'
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

/obj/item/clothing/mask/horsehead/change_speech_verb()
	if(voicechange)
		return pick("whinnies", "neighs", "says")

/obj/item/clothing/mask/face
	flags_inv = HIDEFACE
	flags_cover = MASKCOVERSMOUTH

/obj/item/clothing/mask/face/rat
	name = "rat mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a rat."
	icon_state = "rat"

/obj/item/clothing/mask/face/fox
	name = "fox mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a fox."
	icon_state = "fox"

/obj/item/clothing/mask/face/bee
	name = "bee mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a bee."
	icon_state = "bee"
	sprite_sheets = list("Vox" = 'icons/mob/clothing/species/vox/mask.dmi')

/obj/item/clothing/mask/face/bear
	name = "bear mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a bear."
	icon_state = "bear"

/obj/item/clothing/mask/face/bat
	name = "bat mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a bat."
	icon_state = "bat"

/obj/item/clothing/mask/face/raven
	name = "raven mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a raven."
	icon_state = "raven"

/obj/item/clothing/mask/face/jackal
	name = "jackal mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a jackal."
	icon_state = "jackal"

/obj/item/clothing/mask/face/tribal
	name = "tribal mask"
	desc = "A mask carved out of wood, detailed carefully by hand."
	icon_state = "bumba"

/obj/item/clothing/mask/fawkes
	name = "Guy Fawkes mask"
	desc = "A mask designed to help you remember a specific date."
	icon_state = "fawkes"
	flags_inv = HIDEFACE

// Bandanas
/obj/item/clothing/mask/bandana
	name = "bandana"
	desc = "A colorful bandana."
	flags_inv = HIDEFACE
	flags_cover = MASKCOVERSMOUTH
	w_class = WEIGHT_CLASS_TINY
	adjusted_flags = ITEM_SLOT_HEAD
	icon_state = "bandbotany"
	dyeable = TRUE
	dyeing_key = DYE_REGISTRY_BANDANA
	can_toggle = TRUE

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/mask.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/mask.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/mask.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/mask.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/mask.dmi',
		"Skrell" = 'icons/mob/clothing/species/skrell/mask.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/mask.dmi'
		)
	actions_types = list(/datum/action/item_action/adjust)

/obj/item/clothing/mask/bandana/attack_self__legacy__attackchain(mob/user)
	if(slot_flags & ITEM_SLOT_MASK || slot_flags & ITEM_SLOT_HEAD)
		adjustmask(user)

/obj/item/clothing/mask/bandana/examine(mob/user)
	. = ..()
	if(slot_flags & ITEM_SLOT_NECK)
		. += "Alt-click to untie it to wear as a mask!"
	else
		. += "Alt-click to tie it up to wear on your neck!"


/obj/item/clothing/mask/bandana/AltClick(mob/user)
	if(!iscarbon(user))
		return

	var/mob/living/carbon/char = user
	if((char.get_item_by_slot(ITEM_SLOT_NECK) == src) || (char.get_item_by_slot(ITEM_SLOT_MASK) == src) || (char.get_item_by_slot(ITEM_SLOT_HEAD) == src))
		to_chat(user, ("<span class='warning'>You can't tie [src] while wearing it!</span>"))
		return

	if(slot_flags & ITEM_SLOT_NECK)
		icon = initial(icon)
		flags_inv = initial(flags_inv)
		flags_cover = initial(flags_cover)
		slot_flags = initial(slot_flags)
		icon_state = replacetext(icon_state, "_neck", "")
		dyeable = initial(dyeable)
		can_toggle = initial(can_toggle)

		sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/mask.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/mask.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/mask.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/mask.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/mask.dmi',
		"Skrell" = 'icons/mob/clothing/species/skrell/mask.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/mask.dmi'
		)
		actions_types = list(/datum/action/item_action/adjust)
		var/datum/action/item_action/adjust/act = new(src)
		if(loc == user)
			act.Grant(user)
		to_chat(user, ("<span class='notice'>You untie the neckercheif.</span>"))
	else
		icon = 'icons/obj/clothing/neck.dmi'
		flags_inv = FALSE
		flags_cover = FALSE
		slot_flags = ITEM_SLOT_NECK
		if(up)
			icon_state = replacetext(icon_state, "_up", "")
			up = FALSE
		icon_state += "_neck"
		dyeable = FALSE
		can_toggle = FALSE

		sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/neck.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/neck.dmi',
		)
		actions_types = list()
		for(var/datum/action/item_action/adjust/act in actions)
			act.Remove(user)
			qdel(act)
		to_chat(user, ("<span class='notice'>You tie [src] up like a neckerchief.</span>"))

/obj/item/clothing/mask/bandana/red
	name = "red bandana"
	icon_state = "bandred"
	desc = "It's a red bandana."

/obj/item/clothing/mask/bandana/blue
	name = "blue bandana"
	icon_state = "bandblue"
	desc = "It's a blue bandana."

/obj/item/clothing/mask/bandana/gold
	name = "gold bandana"
	icon_state = "bandgold"
	desc = "It's a gold bandana."

/obj/item/clothing/mask/bandana/green
	name = "green bandana"
	icon_state = "bandgreen"
	desc = "It's a green bandana."

/obj/item/clothing/mask/bandana/orange
	name = "orange bandana"
	icon_state = "bandorange"
	desc = "It's an orange bandana."

/obj/item/clothing/mask/bandana/purple
	name = "purple bandana"
	icon_state = "bandpurple"
	desc = "It's a purple bandana."

/obj/item/clothing/mask/bandana/botany
	name = "botany bandana"
	desc = "It's a green bandana with some fine nanotech lining."

/obj/item/clothing/mask/bandana/skull
	name = "skull bandana"
	desc = "It's a black bandana with a skull pattern."
	icon_state = "bandskull"

/obj/item/clothing/mask/bandana/black
	name = "black bandana"
	icon_state = "bandblack"
	desc = "It's a black bandana."

/obj/item/clothing/mask/bandana/durathread
	name = "durathread bandana"
	desc = "A bandana made from durathread, you wish it would provide some protection to its wearer, but it's far too thin..."
	icon_state = "banddurathread"

/obj/item/clothing/mask/false_cluwne_mask
	name = "cursed clown mask"
	desc = "This is a very, very odd looking mask."
	icon = 'icons/goonstation/objects/clothing/mask.dmi'
	icon_state = "cursedclown"
	worn_icon = 'icons/goonstation/mob/clothing/mask.dmi'
	inhand_icon_state = "cclown_hat"
	lefthand_file = 'icons/goonstation/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/goonstation/mob/inhands/clothing_righthand.dmi'
	flags =	BLOCK_GAS_SMOKE_EFFECT | AIRTIGHT | BLOCKHAIR
	flags_cover = MASKCOVERSMOUTH
	sprite_sheets = list(
		"Drask" = 'icons/mob/clothing/species/drask/mask.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/mask.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/mask.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/mask.dmi'
		)

/obj/item/clothing/mask/cursedclown
	name = "cursed clown mask"
	desc = "This is a very, very odd looking mask."
	icon = 'icons/goonstation/objects/clothing/mask.dmi'
	icon_state = "cursedclown"
	worn_icon = 'icons/goonstation/mob/clothing/mask.dmi'
	inhand_icon_state = "cclown_hat"
	lefthand_file = 'icons/goonstation/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/goonstation/mob/inhands/clothing_righthand.dmi'
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	flags = NODROP | AIRTIGHT | DROPDEL
	flags_cover = MASKCOVERSMOUTH
	sprite_sheets = list(
		"Drask" = 'icons/mob/clothing/species/drask/mask.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/mask.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/mask.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/mask.dmi'
		)

/obj/item/clothing/mask/cursedclown/equipped(mob/user, slot)
	..()
	var/mob/living/carbon/human/H = user
	if(istype(H) && slot == ITEM_SLOT_MASK)
		to_chat(H, "<span class='danger'>[src] grips your face!</span>")
		if(H.mind && H.mind.assigned_role != "Cluwne")
			H.makeCluwne()

/obj/item/clothing/mask/cursedclown/suicide_act(mob/user)
	user.visible_message("<span class='danger'>[user] gazes into the eyes of [src]. [src] gazes back!</span>")
	spawn(10)
		if(user)
			user.gib()
	return OBLITERATION
