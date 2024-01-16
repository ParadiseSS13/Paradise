/obj/item/organ/internal/eyes
	name = "eyeballs"
	icon_state = "eyes"
	gender = PLURAL
	organ_tag = "eyes"
	parent_organ = "head"
	slot = "eyes"
	var/eye_color = "#000000" // Should never be null
	var/list/colourmatrix = null
	var/list/colourblind_matrix = MATRIX_GREYSCALE //Special colourblindness parameters. By default, it's black-and-white.
	var/list/replace_colours = GREYSCALE_COLOR_REPLACE
	var/dependent_disabilities = list() //Gets set by eye-dependent disabilities such as colourblindness so the eyes can transfer the disability during transplantation.
	var/weld_proof = FALSE //If set, the eyes will not take damage during welding. eg. IPC optical sensors do not take damage when they weld things while all other eyes will.

	var/vision_flags = 0
	var/see_in_dark = 2
	var/tint = FLASH_PROTECTION_NONE
	var/flash_protect = FLASH_PROTECTION_NONE
	var/see_invisible = SEE_INVISIBLE_LIVING
	var/lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE

/obj/item/organ/internal/eyes/proc/update_colour()
	dna.write_eyes_attributes(src)

/obj/item/organ/internal/eyes/proc/generate_icon(mob/living/carbon/human/HA)
	var/mob/living/carbon/human/H = HA
	if(!istype(H))
		H = owner
	var/icon/eyes_icon = new /icon('icons/mob/human_face.dmi', H.dna.species.eyes)
	eyes_icon.Blend(eye_color, ICON_ADD)

	return eyes_icon

/obj/item/organ/internal/eyes/proc/get_colourmatrix() //Returns a special colour matrix if the eyes are organic and the mob is colourblind, otherwise it uses the current one.
	if(!is_robotic() && HAS_TRAIT(owner, TRAIT_COLORBLIND))
		return colourblind_matrix
	else
		return colourmatrix

/obj/item/organ/internal/eyes/proc/shine()
	if(is_robotic() || (see_in_dark > EYE_SHINE_THRESHOLD))
		return TRUE

/obj/item/organ/internal/eyes/insert(mob/living/carbon/human/M, special = 0)
	..()
	if(istype(M) && eye_color)
		M.update_body() //Apply our eye colour to the target.

	M.update_tint()
	M.update_sight()

	if(!HAS_TRAIT(M, TRAIT_COLORBLIND) && (TRAIT_COLORBLIND in dependent_disabilities)) //If the eyes are colourblind and we're not, carry over the gene.
		dependent_disabilities -= TRAIT_COLORBLIND
		M.dna.SetSEState(GLOB.colourblindblock, TRUE)
		singlemutcheck(M, GLOB.colourblindblock, MUTCHK_FORCED)
	else
		M.update_client_colour() //If we're here, that means the mob acquired the colourblindness gene while they didn't have eyes. Better handle it.

/obj/item/organ/internal/eyes/remove(mob/living/carbon/human/M, special = 0)
	if(!special && HAS_TRAIT(M, TRAIT_COLORBLIND)) //If special is set, that means these eyes are getting deleted (i.e. during set_species())
		if(!(TRAIT_COLORBLIND in dependent_disabilities)) //We only want to change COLOURBLINDBLOCK and such it the eyes are being surgically removed.
			dependent_disabilities |= TRAIT_COLORBLIND
		M.dna.SetSEState(GLOB.colourblindblock, FALSE)
		singlemutcheck(M, GLOB.colourblindblock, MUTCHK_FORCED)
	. = ..()
	M.update_tint()
	M.update_sight()

/obj/item/organ/internal/eyes/surgeryize()
	if(!owner)
		return
	owner.cure_nearsighted(EYE_DAMAGE)
	owner.cure_blind(EYE_DAMAGE)
	owner.SetEyeBlurry(0)
	owner.SetEyeBlind(0)

/obj/item/organ/internal/eyes/night_vision
	name = "shadow eyes"
	desc = "A spooky set of eyes that can see in the dark."
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	actions_types = list(/datum/action/item_action/organ_action/use)

/obj/item/organ/internal/eyes/night_vision/ui_action_click()
	vision_flags = initial(vision_flags)
	switch(lighting_alpha)
		if(LIGHTING_PLANE_ALPHA_VISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
		if(LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
		if(LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
		else
			lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
			vision_flags &= ~SEE_BLACKNESS
	owner.update_sight()

/obj/item/organ/internal/eyes/night_vision/nightmare
	name = "burning red eyes"
	desc = "Even without their shadowy owner, looking at these eyes gives you a sense of dread."
	icon_state = "burning_eyes"

/obj/item/organ/internal/eyes/robotize(make_tough)
	colourmatrix = null
	..() //Make sure the organ's got the robotic status indicators before updating the client colour.
	if(owner)
		owner.update_client_colour(0) //Since mechanical eyes give see_in_dark of 2 and full colour vision atm, just having this here is fine.

/obj/item/organ/internal/eyes/cybernetic
	name = "cybernetic eyes"
	icon_state = "eyes-c"
	desc = "An electronic device designed to mimic the functions of a pair of human eyes. It has no benefits over organic eyes, but is easy to produce."
	origin_tech = "biotech=4"
	status = ORGAN_ROBOT
	var/flash_intensity = 1

/obj/item/organ/internal/eyes/cybernetic/emp_act(severity)
	if(!owner || emp_proof)
		return
	if(prob(10 * severity))
		return
	to_chat(owner, "<span class='warning'>Static obfuscates your vision!</span>")
	owner.flash_eyes(flash_intensity, visual = TRUE)
	..()

/obj/item/organ/internal/eyes/cybernetic/meson
	name = "meson eyes"
	desc = "These cybernetic eyes will allow you to see the structural layout of the station, and, well, everything else."
	eye_color = "#199900"
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	origin_tech = "materials=4;engineering=4;biotech=4;magnets=4"

/obj/item/organ/internal/eyes/cybernetic/meson/insert(mob/living/carbon/human/M, special = FALSE)
	ADD_TRAIT(M, TRAIT_MESON_VISION, "meson_vision[UID()]")
	return ..()

/obj/item/organ/internal/eyes/cybernetic/meson/remove(mob/living/carbon/human/M, special = FALSE)
	REMOVE_TRAIT(M, TRAIT_MESON_VISION, "meson_vision[UID()]")
	return ..()

/obj/item/organ/internal/eyes/cybernetic/xray
	name = "\improper X-ray eyes"
	desc = "These cybernetic eyes will give you X-ray vision. Blinking is futile."
	see_in_dark = 8
	vision_flags = SEE_MOBS | SEE_OBJS | SEE_TURFS
	origin_tech = "materials=4;programming=4;biotech=7;magnets=4"

/obj/item/organ/internal/eyes/cybernetic/xray/hardened
	name = "hardened X-ray eyes"
	desc = "These cybernetic eyes will give you X-ray vision. Blinking is futile. This pair has been hardened for special operations personnel."
	emp_proof = TRUE
	origin_tech = "materials=6;programming=5;biotech=7;magnets=6;syndicate=3"

/obj/item/organ/internal/eyes/cybernetic/thermals
	name = "thermal eyes"
	desc = "These cybernetic eye implants will give you thermal vision. Vertical slit pupil included."
	eye_color = "#FFCC00"
	vision_flags = SEE_MOBS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	flash_protect = FLASH_PROTECTION_SENSITIVE
	see_in_dark = 8
	origin_tech = "materials=5;programming=4;biotech=4;magnets=4;syndicate=1"

/obj/item/organ/internal/eyes/cybernetic/thermals/hardened
	name = "hardened thermal eyes"
	desc = "These cybernetic eye implants will give you thermal vision. Vertical slit pupil included. This pair has been hardened for special operations personnel."
	emp_proof = TRUE
	origin_tech = "materials=6;programming=5;biotech=6;magnets=6;syndicate=3"

/obj/item/organ/internal/eyes/cybernetic/flashlight
	name = "flashlight eyes"
	desc = "It's two flashlights rigged together with some wire. Why would you put these in someone's head?"
	eye_color ="#FEE5A3"
	icon = 'icons/obj/lighting.dmi'
	icon_state = "flashlight_eyes"
	flash_protect = FLASH_PROTECTION_WELDER
	tint = INFINITY
	var/obj/item/flashlight/eyelight/eye

/obj/item/organ/internal/eyes/cybernetic/flashlight/emp_act(severity)
	return

/obj/item/organ/internal/eyes/cybernetic/flashlight/insert(mob/living/carbon/M, special = FALSE)
	..()
	if(!eye)
		eye = new /obj/item/flashlight/eyelight()
	eye.on = TRUE
	eye.forceMove(M)
	eye.update_brightness(M)
	M.become_blind("flashlight_eyes")


/obj/item/organ/internal/eyes/cybernetic/flashlight/remove(mob/living/carbon/M, special = FALSE)
	if(eye)
		eye.on = FALSE
		eye.update_brightness(M)
		eye.forceMove(src)
	M.cure_blind("flashlight_eyes")
	. = ..()

// Welding shield implant
/obj/item/organ/internal/eyes/cybernetic/shield
	name = "shielded robotic eyes"
	desc = "These reactive micro-shields will protect you from welders and flashes without obscuring your vision."
	flash_protect = FLASH_PROTECTION_WELDER
	eye_color = "#101010"
	origin_tech = "materials=4;biotech=3;engineering=4;plasmatech=3"
	flash_intensity = 3

#define INTACT 0
#define ONE_SHATTERED 1
#define BOTH_SHATTERED 2

/obj/item/organ/internal/eyes/cybernetic/eyesofgod //no occuline allowed
	name = "\improper Eyes of the Gods"
	desc = "Two eyes said to belong to the gods. But such vision comes at a price"
	icon_state = "eyesofgod"
	eye_color = "#58a5ec"
	see_in_dark = 8
	flash_protect = FLASH_PROTECTION_SENSITIVE
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	emp_proof = TRUE //They are crystal artifacts, not metal
	min_bruised_damage = 30
	min_broken_damage = 60
	actions_types = list(/datum/action/item_action/organ_action/use/eyesofgod)
	var/active = FALSE
	var/shatter_state = INTACT

/obj/item/organ/internal/eyes/cybernetic/eyesofgod/Destroy()
	deactivate()
	return ..()

/obj/item/organ/internal/eyes/cybernetic/eyesofgod/remove(mob/living/carbon/human/M, special)
	owner.cure_nearsighted() //Let's not leave the owner with blindness permamently that only admins / re-adding the eyes can remove
	owner.cure_blind()
	deactivate()
	return ..()

/obj/item/organ/internal/eyes/cybernetic/eyesofgod/on_life()
	. = ..()
	if(is_mining_level(owner.z)) //More lavaland use cause magic or something. Don't worry about the ash in peoples eyes.
		heal_internal_damage(0.75, 1)
	if(!active)
		switch(damage)
			if(0 to 10)
				heal_internal_damage(1, 1)
				if(prob(25))
					owner.cure_nearsighted()
					owner.cure_blind()
					unshatter()
			if(10 to 30)
				heal_internal_damage(0.75, 1)
				if(prob(10))
					owner.cure_blind()
					unshatter()
			if(30 to 60)
				heal_internal_damage(0.5, 1)
			if(60 to INFINITY)
				heal_internal_damage(0.33, 1)
	else
		owner.mob_light("#58a5ec", 3, _duration = 2 SECONDS)
		receive_damage(1, 1)
		for(var/obj/O in range(7, owner))
			var/turf/T = get_turf(O)
			for(var/mob/M in O.contents)
				receive_damage(0.25, 1)
				new /obj/effect/temp_visual/eyesofgod(T)
				if(prob(25))
					to_chat(M, "<span class='warning'>You feel like you are being watched...</span>")
		switch(damage)
			if(25 to 30)
				if(prob(50))
					to_chat(owner, "<span class='warning'>Your eyes are burning in your skull!</span>")
					owner.apply_damage(0.5, BURN, parent_organ)
			if(30 to 54)
				receive_damage(0.25, 1) //more pain when damaged
				if(prob(15)) //Warning that you are still hurting yourself still
					to_chat(owner, "<span class='warning'>Your eyes are burning in your skull!</span>")
					owner.apply_damage(0.5, BURN, parent_organ)
			if(55 to 60)
				if(prob(50))
					to_chat(owner, "<span class='warning'>Your eyes feel like they are going to explode!</span>")
					owner.apply_damage(1, BURN, parent_organ)


/obj/item/organ/internal/eyes/cybernetic/eyesofgod/proc/unshatter()
	if(shatter_state == INTACT)
		return
	if(damage <= 10)
		shatter_state = INTACT
	else
		if(shatter_state == ONE_SHATTERED)
			return
		shatter_state = ONE_SHATTERED
	to_chat(owner, "<span class='notice'>Your feel better as your [shatter_state ? "left eye" : "right eye"] fixes itself!</span>")

/obj/item/organ/internal/eyes/cybernetic/eyesofgod/receive_damage(amount, silent)
	. = ..()
	if(damage >= 30 && shatter_state == INTACT || damage >= 60 && shatter_state == ONE_SHATTERED)
		shatter()

/obj/item/organ/internal/eyes/cybernetic/eyesofgod/proc/shatter()
	var/msg = "no eye?"
	switch(shatter_state)
		if(ONE_SHATTERED)
			shatter_state = BOTH_SHATTERED
			msg = "left eye"
			owner.become_blind(EYES_OF_GOD)  //Special flag otherwise occuline heals it :gatto:
		if(INTACT)
			shatter_state = ONE_SHATTERED
			msg = "right eye"
			owner.become_nearsighted(EYES_OF_GOD)
	to_chat(owner, "<span class='userdanger'>You scream out in pain as your [msg] shatters!</span>")
	owner.emote("scream")
	owner.bleed(5)
	deactivate()

/obj/item/organ/internal/eyes/cybernetic/eyesofgod/proc/activate()
	receive_damage(2, 1) //No flicky flicky on / off to fully negate damage
	RegisterSignal(owner, COMSIG_CARBON_FLASH_EYES, PROC_REF(got_flashed))
	active = TRUE
	see_invisible = SEE_INVISIBLE_LEVEL_TWO
	vision_flags = SEE_MOBS | SEE_OBJS | SEE_TURFS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	flash_protect = FLASH_PROTECTION_VERYVUNERABLE //Flashing is it's weakness. I don't care how many protections you have up
	owner?.client?.color = LIGHT_COLOR_PURE_CYAN
	colourmatrix = list(0, 0, 0,\
						0, 1, 0,\
						0, 0, 1)
	owner.update_sight()
	owner.update_eyes_overlay_layer()

/obj/item/organ/internal/eyes/cybernetic/eyesofgod/proc/deactivate()
	UnregisterSignal(owner, COMSIG_CARBON_FLASH_EYES)
	active = FALSE
	see_invisible = initial(see_invisible)
	vision_flags = initial(vision_flags)
	lighting_alpha = initial(lighting_alpha)
	flash_protect = initial(flash_protect)
	owner?.client?.color = null
	colourmatrix = null
	owner.update_sight()
	owner.update_eyes_overlay_layer()

/obj/item/organ/internal/eyes/cybernetic/eyesofgod/proc/got_flashed(mob/living/carbon/C, laser_pointer)
	if(active && !laser_pointer) //Should be active but double checking, and no laser pointer memes, since that is ranged flashes with no skill / counter, unlike a more predectable flashbang
		addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/item/organ, receive_damage), 22), 0.1 SECONDS)//Enough with base flashing to kick people out of vision in a moment due to damage. Don't want to do it instantly, or it lets people take less damage from the base flash

/obj/item/organ/internal/eyes/cybernetic/eyesofgod/ui_action_click()
	if(!active && shatter_state < BOTH_SHATTERED)
		activate()
		return
	deactivate()

/obj/effect/temp_visual/eyesofgod
	name = "eye mark"
	icon_state = "shield_reversed"
	duration = 2 SECONDS
	invisibility = INVISIBILITY_LEVEL_TWO

#undef INTACT
#undef ONE_SHATTERED
#undef BOTH_SHATTERED
