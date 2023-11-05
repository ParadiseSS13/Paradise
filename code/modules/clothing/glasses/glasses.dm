/obj/item/clothing/glasses/Initialize(mapload)
	. = ..()
	if(prescription_upgradable && prescription)
		upgrade_prescription()

/obj/item/clothing/glasses/attackby(obj/item/I, mob/user)
	if(!prescription_upgradable || user.stat || user.restrained() || !ishuman(user))
		return ..()
	var/mob/living/carbon/human/H = user

	// Adding prescription glasses
	if(istype(I, /obj/item/clothing/glasses/regular))
		if(prescription)
			to_chat(H, "<span class='warning'>You can't possibly imagine how adding more lenses would improve [src].</span>")
			return
		H.unEquip(I)
		upgrade_prescription(I)
		to_chat(H, "<span class='notice'>You fit [src] with lenses from [I].</span>")

	// Removing prescription glasses
	H.update_nearsighted_effects()

/obj/item/clothing/glasses/proc/upgrade_prescription(obj/item/I)
	if(!I)
		new /obj/item/clothing/glasses/regular(src)
	else
		I.forceMove(src)
	prescription = TRUE
	name = "prescription [initial(name)]"

/obj/item/clothing/glasses/proc/remove_prescription(mob/living/user)
	var/obj/item/clothing/glasses/regular/prescription_glasses = locate() in src

	if(!prescription_glasses)
		return

	prescription = FALSE
	name = initial(name)

	if(user)
		to_chat(user, "<span class='notice'>You salvage the prescription lenses from [src].</span>")
		user.put_in_hands(prescription_glasses)
		user.update_nearsighted_effects()
	else
		prescription_glasses.forceMove(get_turf(src))

/obj/item/clothing/glasses/screwdriver_act(mob/living/user)
	if(!prescription)
		to_chat(user, "<span class='notice'>There are no prescription lenses in [src].</span>")
		return
	remove_prescription(user)
	return TRUE

/obj/item/clothing/glasses/update_icon_state()
	if(..())
		item_state = "[replacetext("[item_state]", "_up", "")][up ? "_up" : ""]"

/obj/item/clothing/glasses/visor_toggling()
	..()
	if(visor_vars_to_toggle & VISOR_VISIONFLAGS)
		vision_flags ^= initial(vision_flags)
	if(visor_vars_to_toggle & VISOR_DARKNESSVIEW)
		see_in_dark ^= initial(see_in_dark)
	if(visor_vars_to_toggle & VISOR_INVISVIEW)
		invis_view ^= initial(invis_view)

/obj/item/clothing/glasses/weldingvisortoggle(mob/user)
	. = ..()
	if(. && user)
		user.update_sight()
		user.update_inv_glasses()

//called when thermal glasses are emped.
/obj/item/clothing/glasses/proc/thermal_overload()
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		var/obj/item/organ/internal/eyes/eyes = H.get_organ_slot("eyes")
		if(!H.AmountBlinded() && eyes)
			if(H.glasses == src)
				to_chat(H, "<span class='danger'>[src] overloads and blinds you!</span>")
				H.flash_eyes(visual = TRUE)
				H.EyeBlind(6 SECONDS)
				H.EyeBlurry(10 SECONDS)
				eyes.receive_damage(5)

/obj/item/clothing/glasses/meson
	name = "optical meson scanner"
	desc = "Used for seeing walls, floors, and stuff through anything."
	icon_state = "meson"
	item_state = "meson"
	origin_tech = "magnets=1;engineering=2"
	prescription_upgradable = TRUE

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/eyes.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/eyes.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/eyes.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/eyes.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/eyes.dmi'
		)

	var/active_on_equip = TRUE

/obj/item/clothing/glasses/meson/equipped(mob/user, slot, initial)
	. = ..()
	if(active_on_equip && slot == SLOT_HUD_GLASSES)
		ADD_TRAIT(user, TRAIT_MESON_VISION, "meson_glasses[UID()]")

/obj/item/clothing/glasses/meson/dropped(mob/user)
	. = ..()
	if(user)
		REMOVE_TRAIT(user, TRAIT_MESON_VISION, "meson_glasses[UID()]")

/obj/item/clothing/glasses/meson/night
	name = "night vision optical meson scanner"
	desc = "An optical meson scanner fitted with an amplified visible light spectrum overlay, providing greater visual clarity in darkness."
	icon_state = "nvgmeson"
	origin_tech = "magnets=4;engineering=5;plasmatech=4"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE

/obj/item/clothing/glasses/meson/prescription
	prescription = TRUE

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
	sharp = TRUE

/obj/item/clothing/glasses/meson/cyber
	name = "eye replacement implant"
	desc = "An implanted replacement for a left eye with meson vision capabilities."
	icon_state = "cybereye-green"
	item_state = "eyepatch"
	flags = NODROP
	flags_cover = null
	prescription_upgradable = FALSE

/obj/item/clothing/glasses/science
	name = "science goggles"
	desc = "A pair of snazzy goggles used to protect against chemical spills. Fitted with an analyzer for scanning items and reagents."
	icon_state = "purple"
	item_state = "glasses"
	origin_tech = "magnets=2;engineering=1"
	prescription_upgradable = TRUE
	scan_reagents = 1 //You can see reagents while wearing science goggles
	resistance_flags = ACID_PROOF
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 200, ACID = INFINITY)
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/eyes.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/eyes.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/eyes.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/eyes.dmi'
		)
	actions_types = list(/datum/action/item_action/toggle_research_scanner)

/obj/item/clothing/glasses/science/item_action_slot_check(slot)
	if(slot == SLOT_HUD_GLASSES)
		return 1

/obj/item/clothing/glasses/science/night
	name = "night vision science goggles"
	desc = "Now you can science in darkness."
	icon_state = "nvpurple"
	item_state = "glasses"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE //don't render darkness while wearing these

/obj/item/clothing/glasses/janitor
	name = "janitorial goggles"
	desc = "These'll keep the soap out of your eyes."
	icon_state = "purple"
	item_state = "glasses"

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/eyes.dmi'
		)

/obj/item/clothing/glasses/night
	name = "night vision goggles"
	desc = "You can totally see in the dark now!"
	icon_state = "night"
	item_state = "glasses"
	origin_tech = "materials=4;magnets=4;plasmatech=4;engineering=4"
	see_in_dark = 8
	prescription_upgradable = TRUE
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE //don't render darkness while wearing these

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/eyes.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/eyes.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/eyes.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/eyes.dmi'
		)

/obj/item/clothing/glasses/eyepatch
	name = "eyepatch"
	desc = "Yarr."
	icon_state = "eyepatch"
	item_state = "eyepatch"
	prescription_upgradable = TRUE

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/eyes.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/eyes.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/eyes.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/eyes.dmi'
		)

/obj/item/clothing/glasses/monocle
	name = "monocle"
	desc = "Such a dapper eyepiece!"
	icon_state = "monocle"
	item_state = "headset" // lol
	prescription_upgradable = TRUE

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/eyes.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/eyes.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/eyes.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/eyes.dmi'
		)

/obj/item/clothing/glasses/material
	name = "optical material scanner"
	desc = "Very confusing glasses."
	icon_state = "material"
	item_state = "glasses"
	origin_tech = "magnets=3;engineering=3"
	vision_flags = SEE_OBJS

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/eyes.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/eyes.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/eyes.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/eyes.dmi'
		)

/obj/item/clothing/glasses/material/cyber
	name = "eye replacement implant"
	desc = "An implanted replacement for a left eye with material vision capabilities."
	icon_state = "cybereye-blue"
	item_state = "eyepatch"
	flags = NODROP
	flags_cover = null

/obj/item/clothing/glasses/material/lighting
	name = "neutron goggles"
	desc = "These odd glasses use a form of neutron-based imaging to completely negate the effects of light and darkness."
	origin_tech = null
	vision_flags = 0

	flags = NODROP
	lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE

/obj/item/clothing/glasses/regular
	name = "prescription glasses"
	desc = "Made by Nerd. Co."
	icon_state = "glasses"
	item_state = "glasses"
	prescription = TRUE

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/eyes.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/eyes.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/eyes.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/eyes.dmi'
		)

/obj/item/clothing/glasses/regular/hipster
	name = "prescription glasses"
	desc = "Made by Uncool. Co."
	icon_state = "hipster_glasses"
	item_state = "hipster_glasses"

/obj/item/clothing/glasses/goggles
	name = "goggles"
	desc = "Just some basic goggles, rather fashionable."
	icon_state = "goggles"
	item_state = "goggles"

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/eyes.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/eyes.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/eyes.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/eyes.dmi'
		)

/obj/item/clothing/glasses/threedglasses
	name = "\improper 3D glasses"
	desc = "A long time ago, people used these glasses to makes images from screens threedimensional."
	icon_state = "3d"
	item_state = "3d"

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/eyes.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/eyes.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/eyes.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/eyes.dmi'
		)

/obj/item/clothing/glasses/gglasses
	name = "green glasses"
	desc = "Forest green glasses, like the kind you'd wear when hatching a nasty scheme."
	icon_state = "gglasses"
	item_state = "gglasses"

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/eyes.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/eyes.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/eyes.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/eyes.dmi'
		)
	prescription_upgradable = TRUE

/obj/item/clothing/glasses/sunglasses
	name = "sunglasses"
	desc = "Strangely ancient technology used to help provide rudimentary eye cover. Enhanced shielding blocks many flashes."
	icon_state = "sun"
	item_state = "sunglasses"
	see_in_dark = 1
	flash_protect = FLASH_PROTECTION_FLASH
	tint = FLASH_PROTECTION_FLASH
	prescription_upgradable = TRUE
	dog_fashion = /datum/dog_fashion/head
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/eyes.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/eyes.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/eyes.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/eyes.dmi'
		)

/obj/item/clothing/glasses/sunglasses_fake
	name = "cheap sunglasses"
	desc = "Cheap, plastic sunglasses. They don't even have UV protection."
	icon_state = "sun"
	item_state = "sunglasses"
	see_in_dark = 0
	flash_protect = FLASH_PROTECTION_NONE
	tint = FLASH_PROTECTION_NONE
	prescription_upgradable = TRUE

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/eyes.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/eyes.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/eyes.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/eyes.dmi'
		)

/obj/item/clothing/glasses/sunglasses/noir
	name = "noir sunglasses"
	desc = "Somehow these seem even more out-of-date than normal sunglasses."
	actions_types = list(/datum/action/item_action/noir)

/obj/item/clothing/glasses/sunglasses/noir/attack_self(mob/user)
	toggle_noir(user)

/obj/item/clothing/glasses/sunglasses/noir/item_action_slot_check(slot)
	if(slot == SLOT_HUD_GLASSES)
		return 1

/obj/item/clothing/glasses/sunglasses/noir/proc/toggle_noir(mob/user)
	color_view = color_view ? null : MATRIX_GREYSCALE //Toggles between null and grayscale, with null being the default option.
	user.update_client_colour()

/obj/item/clothing/glasses/sunglasses/yeah
	name = "agreeable glasses"
	desc = "H.C Limited edition."
	var/punused = FALSE
	actions_types = list(/datum/action/item_action/YEEEAAAAAHHHHHHHHHHHHH)

/obj/item/clothing/glasses/sunglasses/yeah/attack_self(mob/user)
	pun(user)

/obj/item/clothing/glasses/sunglasses/yeah/proc/pun(mob/user)
	if(punused) // one per round..
		to_chat(user, "The moment is gone.")
		return

	punused = TRUE
	playsound(loc, 'sound/misc/yeah.ogg', 100, FALSE)
	user.visible_message("<span class='biggerdanger'>YEEEAAAAAHHHHHHHHHHHHH!!</span>")
	if(HAS_TRAIT(user, TRAIT_BADASS)) //unless you're badass
		addtimer(VARSET_CALLBACK(src, punused, FALSE), 5 MINUTES)

/obj/item/clothing/glasses/sunglasses/reagent
	name = "sunscanners"
	desc = "Strangely ancient technology used to help provide rudimentary eye cover. Outfitted with an apparatus to scan individual reagents, tech potentials, and machines internal components."
	scan_reagents = 1
	actions_types = list(/datum/action/item_action/toggle_research_scanner)

/obj/item/clothing/glasses/sunglasses/reagent/item_action_slot_check(slot)
	if(slot == SLOT_HUD_GLASSES)
		return TRUE

/obj/item/clothing/glasses/virussunglasses
	name = "sunglasses"
	desc = "Strangely ancient technology used to help provide rudimentary eye cover. Enhanced shielding blocks many flashes."
	icon_state = "sun"
	item_state = "sunglasses"
	see_in_dark = 1
	flash_protect = FLASH_PROTECTION_FLASH
	tint = FLASH_PROTECTION_FLASH

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/eyes.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/eyes.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/eyes.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/eyes.dmi'
		)

/obj/item/clothing/glasses/sunglasses/lasers
	name = "high-tech sunglasses"
	desc = "A peculiar set of sunglasses; they have various chips and other panels attached to the sides of the frames."
	flags = NODROP

/obj/item/clothing/glasses/sunglasses/lasers/equipped(mob/user, slot) //grant them laser eyes upon equipping it.
	if(slot == SLOT_HUD_GLASSES)
		ADD_TRAIT(user, TRAIT_LASEREYES, "admin_zapglasses")
		user.regenerate_icons()
	..(user, slot)

/obj/item/clothing/glasses/welding
	name = "welding goggles"
	desc = "Protects the eyes from welders, approved by the mad scientist association."
	icon_state = "welding-g"
	item_state = "welding-g"
	actions_types = list(/datum/action/item_action/toggle)
	flash_protect = FLASH_PROTECTION_WELDER
	tint = FLASH_PROTECTION_WELDER
	can_toggle = TRUE
	visor_vars_to_toggle = VISOR_FLASHPROTECT | VISOR_TINT
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/eyes.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/eyes.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/eyes.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/eyes.dmi'
		)

/obj/item/clothing/glasses/welding/attack_self(mob/user)
	weldingvisortoggle(user)

/obj/item/clothing/glasses/welding/superior
	name = "superior welding goggles"
	desc = "Welding goggles made from more expensive materials, strangely smells like potatoes."
	icon_state = "rwelding-g"
	item_state = "rwelding-g"
	flash_protect = FLASH_PROTECTION_WELDER
	tint = FLASH_PROTECTION_NONE

/obj/item/clothing/glasses/sunglasses/blindfold
	name = "blindfold"
	desc = "Covers the eyes, preventing sight."
	icon_state = "blindfold"
	item_state = "blindfold"
	flash_protect = FLASH_PROTECTION_WELDER
	tint = 3				//to make them blind
	prescription_upgradable = FALSE

/obj/item/clothing/glasses/sunglasses/blindfold/fake
	name = "tattered blindfold"
	desc = "A see-through blindfold perfect for cheating at games like pin the stunbaton on the clown."
	flash_protect = FLASH_PROTECTION_NONE
	tint = FLASH_PROTECTION_NONE

/obj/item/clothing/glasses/sunglasses/prescription
	prescription = TRUE

/obj/item/clothing/glasses/sunglasses/big
	desc = "Strangely ancient technology used to help provide rudimentary eye cover. Larger than average enhanced shielding blocks many flashes."
	icon_state = "bigsunglasses"
	item_state = "bigsunglasses"

/obj/item/clothing/glasses/thermal
	name = "optical thermal scanner"
	desc = "Thermals in the shape of glasses."
	icon_state = "thermal"
	item_state = "glasses"
	origin_tech = "magnets=3"
	vision_flags = SEE_MOBS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	flash_protect = FLASH_PROTECTION_SENSITIVE

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/eyes.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/eyes.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/eyes.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/eyes.dmi'
		)

/obj/item/clothing/glasses/thermal/emp_act(severity)
	thermal_overload()
	..()

/obj/item/clothing/glasses/thermal/monocle
	name = "thermonocle"
	desc = "A thermal monocle."
	icon_state = "thermonocle"
	flags_cover = null //doesn't protect eyes because it's a monocle, duh

/obj/item/clothing/glasses/thermal/eyepatch
	name = "optical thermal eyepatch"
	desc = "An eyepatch with built-in thermal optics"
	icon_state = "eyepatch"
	item_state = "eyepatch"

/obj/item/clothing/glasses/thermal/jensen
	name = "optical thermal implant"
	desc = "A set of implantable lenses designed to augment your vision"
	icon_state = "thermalimplants"
	item_state = "syringe_kit"

/obj/item/clothing/glasses/thermal/cyber
	name = "eye replacement implant"
	desc = "An implanted replacement for a left eye with thermal vision capabilities."
	icon_state = "cybereye-red"
	item_state = "eyepatch"
	flags = NODROP

/obj/item/clothing/glasses/tajblind
	name = "embroidered veil"
	desc = "An Ahdominian made veil that allows the user to see while obscuring their eyes."
	icon_state = "tajblind"
	item_state = "tajblind"
	flags_cover = GLASSESCOVERSEYES
	actions_types = list(/datum/action/item_action/toggle)
	up = FALSE
	tint = FLASH_PROTECTION_NONE
	prescription_upgradable = TRUE

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/eyes.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/eyes.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/eyes.dmi'
		)

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
	if(HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED) || usr.incapacitated())
		return
	up = !up
	if(up)
		tint = 3
	else
		tint = initial(tint)
	to_chat(usr, up ? "You deactivate [src], obscuring your vision." : "You activate [src], allowing you to see.")
	var/mob/living/carbon/user = usr
	user.update_tint()
	user.update_inv_glasses()
