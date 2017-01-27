/obj/item/clothing/glasses/New()
	. = ..()
	if(prescription_upgradable && prescription)
		// Pre-upgraded upgradable glasses
		name = "prescription [name]"

/obj/item/clothing/glasses/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(user.stat || user.restrained() || !ishuman(user))
		return ..()
	var/mob/living/carbon/human/H = user
	if(prescription_upgradable)
		if(istype(O, /obj/item/clothing/glasses/regular))
			if(prescription)
				to_chat(H, "You can't possibly imagine how adding more lenses would improve \the [name].")
				return
			H.unEquip(O)
			O.loc = src // Store the glasses for later removal
			to_chat(H, "You fit \the [name] with lenses from \the [O].")
			prescription = 1
			name = "prescription [name]"
			return
		if(prescription && istype(O, /obj/item/weapon/screwdriver))
			var/obj/item/clothing/glasses/regular/G = locate() in src
			if(!G)
				G = new(get_turf(H))
			to_chat(H, "You salvage the prescription lenses from \the [name].")
			prescription = 0
			name = initial(name)
			H.put_in_hands(G)
			return
	return ..()

/obj/item/clothing/glasses/meson
	name = "Optical Meson Scanner"
	desc = "Used for seeing walls, floors, and stuff through anything."
	icon_state = "meson"
	item_state = "glasses"
	origin_tech = "magnets=2;engineering=2"
	vision_flags = SEE_TURFS
	invis_view = SEE_INVISIBLE_MINIMUM //don't render darkness while wearing these
	prescription_upgradable = 1
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/eyes.dmi',
		"Drask" = 'icons/mob/species/drask/eyes.dmi'
		)

/obj/item/clothing/glasses/meson/night
	name = "Night Vision Optical Meson Scanner"
	desc = "An Optical Meson Scanner fitted with an amplified visible light spectrum overlay, providing greater visual clarity in darkness."
	icon_state = "nvgmeson"
	item_state = "glasses"
	darkness_view = 8
	prescription_upgradable = 0

/obj/item/clothing/glasses/meson/prescription
	prescription = 1

/obj/item/clothing/glasses/meson/gar
	name = "gar mesons"
	icon_state = "garm"
	item_state = "garm"
	desc = "Do the impossible, see the invisible!"
	force = 10
	throwforce = 10
	throw_speed = 4
	attack_verb = list("sliced")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharp = 1
	edge = 1

/obj/item/clothing/glasses/meson/cyber
	name = "Eye Replacement Implant"
	desc = "An implanted replacement for a left eye with meson vision capabilities."
	icon_state = "cybereye-green"
	item_state = "eyepatch"
	flags = NODROP
	prescription_upgradable = 0

/obj/item/clothing/glasses/science
	name = "science goggles"
	desc = "A pair of snazzy goggles used to protect against chemical spills. Fitted with an analyzer for scanning items and reagents."
	icon_state = "purple"
	item_state = "glasses"
	prescription_upgradable = 0
	scan_reagents = 1 //You can see reagents while wearing science goggles
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/eyes.dmi'
		)
	actions_types = list(/datum/action/item_action/toggle_research_scanner)

/obj/item/clothing/glasses/science/item_action_slot_check(slot)
	if(slot == slot_glasses)
		return 1

/obj/item/clothing/glasses/science/night
	name = "Night Vision Science Goggle"
	desc = "Now you can science in darkness."
	icon_state = "nvpurple"
	item_state = "glasses"
	darkness_view = 8
	invis_view = SEE_INVISIBLE_MINIMUM //don't render darkness while wearing these

/obj/item/clothing/glasses/janitor
	name = "Janitorial Goggles"
	desc = "These'll keep the soap out of your eyes."
	icon_state = "purple"
	item_state = "glasses"
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/eyes.dmi'
		)

/obj/item/clothing/glasses/night
	name = "Night Vision Goggles"
	desc = "You can totally see in the dark now!"
	icon_state = "night"
	item_state = "glasses"
	origin_tech = "magnets=2"
	darkness_view = 8
	invis_view = SEE_INVISIBLE_MINIMUM //don't render darkness while wearing these
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/eyes.dmi',
		"Drask" = 'icons/mob/species/drask/eyes.dmi'
		)

/obj/item/clothing/glasses/eyepatch
	name = "eyepatch"
	desc = "Yarr."
	icon_state = "eyepatch"
	item_state = "eyepatch"
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/eyes.dmi'
		)

/obj/item/clothing/glasses/monocle
	name = "monocle"
	desc = "Such a dapper eyepiece!"
	icon_state = "monocle"
	item_state = "headset" // lol
	prescription_upgradable = 1
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/eyes.dmi',
		"Drask" = 'icons/mob/species/drask/eyes.dmi'
		)

/obj/item/clothing/glasses/material
	name = "Optical Material Scanner"
	desc = "Very confusing glasses."
	icon_state = "material"
	item_state = "glasses"
	origin_tech = "magnets=3;engineering=3"
	vision_flags = SEE_OBJS
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/eyes.dmi',
		"Drask" = 'icons/mob/species/drask/eyes.dmi'
		)

/obj/item/clothing/glasses/material/cyber
	name = "Eye Replacement Implant"
	desc = "An implanted replacement for a left eye with material vision capabilities."
	icon_state = "cybereye-blue"
	item_state = "eyepatch"
	flags = NODROP

/obj/item/clothing/glasses/regular
	name = "prescription glasses"
	desc = "Made by Nerd. Co."
	icon_state = "glasses"
	item_state = "glasses"
	prescription = 1
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/eyes.dmi'
		)

/obj/item/clothing/glasses/regular/hipster
	name = "prescription glasses"
	desc = "Made by Uncool. Co."
	icon_state = "hipster_glasses"
	item_state = "hipster_glasses"

/obj/item/clothing/glasses/threedglasses
	desc = "A long time ago, people used these glasses to makes images from screens threedimensional."
	name = "3D glasses"
	icon_state = "3d"
	item_state = "3d"
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/eyes.dmi'
		)

/obj/item/clothing/glasses/gglasses
	name = "Green Glasses"
	desc = "Forest green glasses, like the kind you'd wear when hatching a nasty scheme."
	icon_state = "gglasses"
	item_state = "gglasses"
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/eyes.dmi'
		)
	prescription_upgradable = 1

/obj/item/clothing/glasses/sunglasses
	desc = "Strangely ancient technology used to help provide rudimentary eye cover. Enhanced shielding blocks many flashes."
	name = "sunglasses"
	icon_state = "sun"
	item_state = "sunglasses"
	darkness_view = 1
	flash_protect = 1
	tint = 1
	prescription_upgradable = 1
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/eyes.dmi',
		"Drask" = 'icons/mob/species/drask/eyes.dmi'
		)

/obj/item/clothing/glasses/sunglasses/fake
	desc = "Cheap, plastic sunglasses. They don't even have UV protection."
	name = "cheap sunglasses"
	darkness_view = 0
	flash_protect = 0
	tint = 0

/obj/item/clothing/glasses/sunglasses/noir
	name = "noir sunglasses"
	desc = "Somehow these seem even more out-of-date than normal sunglasses."
	actions_types = list(/datum/action/item_action/noir, /datum/action/item_action/monologue)
	var/noir_mode = 0
	color_view = MATRIX_GREYSCALE

/obj/item/clothing/glasses/sunglasses/noir/ui_action_click(mob/user, actiontype)
	if(actiontype == /datum/action/item_action/noir)
		attack_self()
	else if(actiontype == /datum/action/item_action/monologue)
		monologue(user)

/obj/item/clothing/glasses/sunglasses/noir/proc/monologue(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	var/vox = (H.get_species() == "Vox" || H.get_species() == "Vox Armalis")
	var/message = null //for visible_message
	var/monologue = null
	var/area/A = get_area(H)

	if(H.is_muzzled())
		message = "<B>[src]</B> struggles against \the [H.wear_mask]. [H.gender == MALE ? "H" : "Sh"]e's not giving up so easily."
	else if(istype(H.l_hand, /obj/item/weapon/grab) && H.l_hand:state >= 3)//won't runtime because it quits if the first check fails
		if(ishuman(H.l_hand:affecting))//again, if it gets here it won't be able to runtime
			if(!vox)
				monologue = "I'll stare the bastard in the face as he screams to God, and I'll laugh harder when he whimpers like a baby. And when [H.l_hand:affecting]'s eyes go dead, the hell I send him to will seem like heaven after what I've done to him."
			else
				monologue = "Youses is skrek and is goes where skrek comes from!"
	else if(istype(H.r_hand, /obj/item/weapon/grab) && H.r_hand:state >= 3)
		if(ishuman(H.r_hand:affecting))
			if(!vox)
				monologue = "I'll stare the bastard in the face as he screams to God, and I'll laugh harder when he whimpers like a baby. And when [H.r_hand:affecting]'s eyes go dead, the hell I send him to will seem like heaven after what I've done to him."
			else
				monologue = "Youses is skrek and is goes where skrek comes from!"
	else if(istype(H.r_hand, /obj/item/weapon/gun/projectile/revolver/detective))
		if(!vox)
			monologue = "Ah, [H.r_hand]. [pick("They say anything can be solved with just enough violence.", "Around here you're the only ally I can count on.", "In this hellhole there isn't anyone else I'd rather have at my side.")]"
		else
			monologue = "[H.r_hand], monologue. [pick("Voxxy was never a fan of the Involate. Not when with you at Voxxy's side.", "The dustlungs will not understand.", "Voxxy has seen enough to know you're the closest friend Voxxy has.")]"
	else if(istype(H.l_hand, /obj/item/weapon/gun/projectile/revolver/detective))
		if(!vox)
			monologue = "Ah, [H.l_hand]. [pick("They say anything can be solved with just enough violence.", "Around here you're the only ally I can count on.", "In this hellhole there isn't anyone else I'd rather have at my side.")]"
		else
			monologue = "[H.l_hand], monologue. [pick("Voxxy was never a fan of the Involate. Not when with you at Voxxy's side.", "The dustlungs will not understand.", "Voxxy has seen enough to know you're the closest friend Voxxy has.")]"
	else if(istype(H.r_hand, /obj/item/device/detective_scanner) || istype(H.l_hand, /obj/item/device/detective_scanner))
		if(!vox)
			monologue = "They don't call me a Detective for nothing. It was time to get busy."
		else
			monologue = "Voxxy had to start investigating. Something didn't seem right."
	else if(ROUND_TIME < 600)//first 1 minute of the shift
		if(!vox)
			monologue = "Noon. I could hear the initial hustle in the distance, but the hallways seemed darker than usual. It was going to be a long shift."
		else
			monologue = "Was dark station at starts, monologue. Would be long shift."
	else if(H.drunk > 20)//boozed up detective
		if(!vox)
			monologue = "I had told myself it would have been the last time, but I just couldn't take it anymore. Scotch was the only friend I had left."
		else
			monologue = "Shoal always say waste as little as neccessary. But sometimes me just feel like getting wasted. Shoal would never understand."
	else if(A.get_monologue(H.species))
		monologue = A.get_monologue(H.species)
	else if(istype(H.wear_mask, /obj/item/clothing/mask/cigarette))
		if(H.get_species() == "Machine")
			message = "<B>[src]</B> buzzes quietly, surveying the scene around them carefullly."
		else
			if(!vox)
				message = "<B>[src]</B> takes a drag on \his [H.wear_mask], surveying the scene around them carefullly."
			else
				message = "<B>[src]</b> takes a clumsy drag on \his [H.wear_mask], winces and gives off a few dry coughs."//don't smoke, skreks
	else
		message = "<B>[src]</B> looks uneasy, like [gender == MALE ? "" : "s"]he's missing a vital part of h[gender == MALE ? "im" : "er"]self. [gender == MALE ? "H" : "Sh"]e needs a smoke badly."

	if(message)
		H.visible_message(message)
	else if(monologue)
		H.say(monologue)

/obj/item/clothing/glasses/sunglasses/noir/attack_self()
	toggle_noir()

/obj/item/clothing/glasses/sunglasses/noir/item_action_slot_check(slot)
	if(slot == slot_glasses)
		return 1

/obj/item/clothing/glasses/sunglasses/noir/proc/toggle_noir()
	var/list/difference = difflist(usr.client.color, color_view)

	if(!noir_mode)
		if(color_view && usr.client && (!usr.client.color || difference))
			animate(usr.client, color = color_view, time = 10)
			noir_mode = 1
	else
		if(usr.client && usr.client.color && !difference)
			animate(usr.client, color = initial(usr.client.color), time = 10)
			noir_mode = 0

/obj/item/clothing/glasses/sunglasses/noir/equipped(mob/user, slot)
	var/list/difference = difflist(user.client.color, color_view)

	if(slot == slot_glasses)
		if(noir_mode)
			if(color_view && user.client && (!user.client.color || difference.len))
				animate(user.client, color = color_view, time = 10)
	else
		if(user.client && user.client.color && !difference.len)
			animate(user.client, color = initial(user.client.color), time = 10)
	..(user, slot)

/obj/item/clothing/glasses/sunglasses/noir/dropped(mob/living/carbon/human/user)
	var/list/difference = difflist(user.client.color, color_view)

	if(istype(user) && user.glasses == src)
		if(user.client && user.client.color && !difference.len)
			animate(user.client, color = initial(user.client.color), time = 10)
	..(user)

/obj/item/clothing/glasses/sunglasses/yeah
	name = "agreeable glasses"
	desc = "H.C Limited edition."
	var/punused = null
	actions_types = list(/datum/action/item_action/YEEEAAAAAHHHHHHHHHHHHH)

/obj/item/clothing/glasses/sunglasses/yeah/attack_self()
	pun()

/obj/item/clothing/glasses/sunglasses/yeah/proc/pun()
	if(!punused)//one per round
		punused = 1
		playsound(src.loc, 'sound/misc/yeah.ogg', 100, 0)
		usr.visible_message("<span class='biggerdanger'>YEEEAAAAAHHHHHHHHHHHHH!!</span>")
	else
		to_chat(usr, "The moment is gone.")


/obj/item/clothing/glasses/sunglasses/reagent
	name = "sunscanners"
	desc = "Strangely ancient technology used to help provide rudimentary eye color. Outfitted with apparatus to scan individual reagents."
	scan_reagents = 1

/obj/item/clothing/glasses/virussunglasses
	desc = "Strangely ancient technology used to help provide rudimentary eye cover. Enhanced shielding blocks many flashes."
	name = "sunglasses"
	icon_state = "sun"
	item_state = "sunglasses"
	darkness_view = 1
	flash_protect = 1
	tint = 1
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/eyes.dmi',
		"Drask" = 'icons/mob/species/drask/eyes.dmi'
		)

/obj/item/clothing/glasses/sunglasses/lasers
	desc = "A peculiar set of sunglasses; they have various chips and other panels attached to the sides of the frames."
	name = "high-tech sunglasses"
	flags = GLASSESCOVERSEYES | NODROP

/obj/item/clothing/glasses/sunglasses/lasers/equipped(mob/user, slot) //grant them laser eyes upon equipping it.
	if(slot == slot_glasses)
		user.mutations.Add(LASER)
		user.regenerate_icons()
	..(user, slot)

/obj/item/clothing/glasses/welding
	name = "welding goggles"
	desc = "Protects the eyes from welders, approved by the mad scientist association."
	icon_state = "welding-g"
	item_state = "welding-g"
	actions_types = list(/datum/action/item_action/toggle)
	flash_protect = 2
	tint = 2
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/eyes.dmi',
		"Drask" = 'icons/mob/species/drask/eyes.dmi'
		)

/obj/item/clothing/glasses/welding/attack_self()
	toggle()

/obj/item/clothing/glasses/welding/proc/toggle()
	if(up)
		up = !up
		flags |= GLASSESCOVERSEYES
		flags_inv |= HIDEEYES
		icon_state = initial(icon_state)
		to_chat(usr, "You flip the [src] down to protect your eyes.")
		flash_protect = 2
		tint = initial(tint) //better than istype
	else
		up = !up
		flags &= ~GLASSESCOVERSEYES
		flags_inv &= ~HIDEEYES
		icon_state = "[initial(icon_state)]up"
		to_chat(usr, "You push the [src] up out of your face.")
		flash_protect = 0
		tint = 0
	var/mob/living/carbon/user = usr
	user.update_inv_glasses()
	user.update_tint()

	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/clothing/glasses/welding/superior
	name = "superior welding goggles"
	desc = "Welding goggles made from more expensive materials, strangely smells like potatoes."
	icon_state = "rwelding-g"
	item_state = "rwelding-g"
	flash_protect = 2
	tint = 0

/obj/item/clothing/glasses/sunglasses/blindfold
	name = "blindfold"
	desc = "Covers the eyes, preventing sight."
	icon_state = "blindfold"
	item_state = "blindfold"
	//vision_flags = BLIND
	flash_protect = 2
	tint = 3				//to make them blind
	prescription_upgradable = 0

/obj/item/clothing/glasses/sunglasses/prescription
	prescription = 1

/obj/item/clothing/glasses/sunglasses/big
	desc = "Strangely ancient technology used to help provide rudimentary eye cover. Larger than average enhanced shielding blocks many flashes."
	icon_state = "bigsunglasses"
	item_state = "bigsunglasses"

/obj/item/clothing/glasses/thermal
	name = "Optical Thermal Scanner"
	desc = "Thermals in the shape of glasses."
	icon_state = "thermal"
	item_state = "glasses"
	origin_tech = "magnets=3"
	vision_flags = SEE_MOBS
	flash_protect = -1
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/eyes.dmi'
		)

	emp_act(severity)
		if(istype(src.loc, /mob/living/carbon/human))
			var/mob/living/carbon/human/M = src.loc
			to_chat(M, "\red The Optical Thermal Scanner overloads and blinds you!")
			if(M.glasses == src)
				M.EyeBlind(3)
				M.EyeBlurry(5)
				if(!(M.disabilities & NEARSIGHTED))
					M.BecomeNearsighted()
					spawn(100)
						M.CureNearsighted()
		..()

/obj/item/clothing/glasses/thermal/syndi	//These are now a traitor item, concealed as mesons.	-Pete
	name = "Optical Meson Scanner"
	desc = "Used for seeing walls, floors, and stuff through anything."
	icon_state = "meson"
	origin_tech = "magnets=3;syndicate=4"
	prescription_upgradable = 1

/obj/item/clothing/glasses/thermal/monocle
	name = "Thermoncle"
	desc = "A monocle thermal."
	icon_state = "thermoncle"
	flags = null //doesn't protect eyes because it's a monocle, duh

/obj/item/clothing/glasses/thermal/eyepatch
	name = "Optical Thermal Eyepatch"
	desc = "An eyepatch with built-in thermal optics"
	icon_state = "eyepatch"
	item_state = "eyepatch"

/obj/item/clothing/glasses/thermal/jensen
	name = "Optical Thermal Implants"
	desc = "A set of implantable lenses designed to augment your vision"
	icon_state = "thermalimplants"
	item_state = "syringe_kit"

/obj/item/clothing/glasses/thermal/cyber
	name = "Eye Replacement Implant"
	desc = "An implanted replacement for a left eye with thermal vision capabilities."
	icon_state = "cybereye-red"
	item_state = "eyepatch"
	flags = NODROP

/obj/item/clothing/glasses/proc/chameleon(var/mob/user)
	var/input_glasses = input(user, "Choose a piece of eyewear to disguise as.", "Choose glasses style.") as null|anything in list("Sunglasses", "Medical HUD", "Mesons", "Science Goggles", "Glasses", "Security Sunglasses","Eyepatch","Welding","Gar")

	if(user && src in user.contents)
		switch(input_glasses)
			if("Sunglasses")
				desc = "Strangely ancient technology used to help provide rudimentary eye cover. Enhanced shielding blocks many flashes."
				name = "sunglasses"
				icon_state = "sun"
				item_state = "sunglasses"
			if("Medical HUD")
				name = "Health Scanner HUD"
				desc = "A heads-up display that scans the humans in view and provides accurate data about their health status."
				icon_state = "healthhud"
				item_state = "healthhud"
			if("Mesons")
				name = "Optical Meson Scanner"
				desc = "Used by engineering and mining staff to see basic structural and terrain layouts through walls, regardless of lighting condition."
				icon_state = "meson"
				item_state = "meson"
			if("Science Goggles")
				name = "Science Goggles"
				desc = "A pair of snazzy goggles used to protect against chemical spills."
				icon_state = "purple"
				item_state = "glasses"
			if("Glasses")
				name = "Prescription Glasses"
				desc = "Made by Nerd. Co."
				icon_state = "glasses"
				item_state = "glasses"
			if("Security Sunglasses")
				name = "HUDSunglasses"
				desc = "Sunglasses with a HUD."
				icon_state = "sunhud"
				item_state = "sunglasses"
			if("Eyepatch")
				name = "eyepatch"
				desc = "Yarr."
				icon_state = "eyepatch"
				item_state = "eyepatch"
			if("Welding")
				name = "welding goggles"
				desc = "Protects the eyes from welders; approved by the mad scientist association."
				icon_state = "welding-g"
				item_state = "welding-g"
			if("Gar")
				desc = "Just who the hell do you think I am?!"
				name = "gar glasses"
				icon_state = "gar"
				item_state = "gar"
