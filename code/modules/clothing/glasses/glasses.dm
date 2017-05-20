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
		"Drask" = 'icons/mob/species/drask/eyes.dmi',
		"Grey" = 'icons/mob/species/grey/eyes.dmi'
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
	flags_cover = null
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
		"Drask" = 'icons/mob/species/drask/eyes.dmi',
		"Grey" = 'icons/mob/species/grey/eyes.dmi'
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
	flags_cover = null

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
		"Drask" = 'icons/mob/species/drask/eyes.dmi',
		"Grey" = 'icons/mob/species/grey/eyes.dmi'
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
	actions_types = list(/datum/action/item_action/noir)

/obj/item/clothing/glasses/sunglasses/noir/attack_self()
	toggle_noir()

/obj/item/clothing/glasses/sunglasses/noir/item_action_slot_check(slot)
	if(slot == slot_glasses)
		return 1

/obj/item/clothing/glasses/sunglasses/noir/proc/toggle_noir()
	color_view = color_view ? null : MATRIX_GREYSCALE //Toggles between null and grayscale, with null being the default option.
	usr.update_client_colour()

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
		"Drask" = 'icons/mob/species/drask/eyes.dmi',
		"Grey" = 'icons/mob/species/grey/eyes.dmi'
		)

/obj/item/clothing/glasses/sunglasses/lasers
	desc = "A peculiar set of sunglasses; they have various chips and other panels attached to the sides of the frames."
	name = "high-tech sunglasses"
	flags = NODROP

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
		"Drask" = 'icons/mob/species/drask/eyes.dmi',
		"Grey" = 'icons/mob/species/grey/eyes.dmi'
		)

/obj/item/clothing/glasses/welding/attack_self()
	toggle()

/obj/item/clothing/glasses/welding/proc/toggle()
	if(up)
		up = !up
		flags_cover |= GLASSESCOVERSEYES
		flags_inv |= HIDEEYES
		icon_state = initial(icon_state)
		to_chat(usr, "You flip the [src] down to protect your eyes.")
		flash_protect = 2
		tint = initial(tint) //better than istype
	else
		up = !up
		flags_cover &= ~GLASSESCOVERSEYES
		flags_inv &= ~HIDEEYES
		icon_state = "[initial(icon_state)]up"
		to_chat(usr, "You push the [src] up out of your face.")
		flash_protect = 0
		tint = 0
	var/mob/living/carbon/user = usr
	user.update_tint()
	user.update_inv_glasses()

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
			to_chat(M, "<span class='warning'>The Optical Thermal Scanner overloads and blinds you!</span>")
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
	flags_cover = null //doesn't protect eyes because it's a monocle, duh

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

/obj/item/clothing/glasses/godeye
	name = "eye of god"
	desc = "A strange eye, said to have been torn from an omniscient creature that used to roam the wastes."
	icon_state = "godeye"
	item_state = "godeye"
	vision_flags = SEE_TURFS|SEE_MOBS|SEE_OBJS
	darkness_view = 8
	scan_reagents = 1
	flags = NODROP
	flags_cover = null
	invis_view = SEE_INVISIBLE_MINIMUM

/obj/item/clothing/glasses/godeye/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(istype(W, src) && W != src && W.loc == user)
		if(W.icon_state == "godeye")
			W.icon_state = "doublegodeye"
			W.item_state = "doublegodeye"
			W.desc = "A pair of strange eyes, said to have been torn from an omniscient creature that used to roam the wastes. There's no real reason to have two, but that isn't stopping you."
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.update_inv_wear_mask()
		else
			to_chat(user, "<span class='notice'>The eye winks at you and vanishes into the abyss, you feel really unlucky.</span>")
		qdel(src)
	..()

/obj/item/clothing/glasses/tajblind
	name = "embroidered veil"
	desc = "An Ahdominian made veil that allows the user to see while obscuring their eyes."
	icon_state = "tajblind"
	item_state = "tajblind"
	flags_cover = GLASSESCOVERSEYES
	actions_types = list(/datum/action/item_action/toggle)
	up = 0
	tint = 0

/obj/item/clothing/glasses/tajblind/eng
	name = "industrial veil"
	icon_state = "tajblind_engi"
	item_state = "tajblind_engi"

/obj/item/clothing/glasses/tajblind/sci
	name = "hi-tech veil"
	icon_state = "tajblind_sci"
	item_state = "tajblind_sci"

/obj/item/clothing/glasses/tajblind/cargo
	name = "khaki veil"
	icon_state = "tajblind_cargo"
	item_state = "tajblind_cargo"

/obj/item/clothing/glasses/tajblind/attack_self()
	toggle_veil()

/obj/item/clothing/glasses/proc/toggle_veil()
	if(usr.canmove && !usr.incapacitated())
		if(up)
			up = !up
			tint = initial(tint)
			to_chat(usr, "You activate [src], allowing you to see.")
		else
			up = !up
			tint = 3
			to_chat(usr, "You deactivate [src], obscuring your vision.")
		var/mob/living/carbon/user = usr
		user.update_tint()
		user.update_inv_glasses()