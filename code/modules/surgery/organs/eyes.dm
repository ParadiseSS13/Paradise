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
	var/tint = 0
	var/flash_protect = FLASH_PROTECTION_NONE
	var/see_invisible = SEE_INVISIBLE_LIVING
	var/lighting_alpha

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

/obj/item/organ/internal/eyes/cybernetic/emp_act(severity)
	if(!owner || emp_proof)
		return
	if(prob(10 * severity))
		return
	to_chat(owner, "<span class='warning'>Static obfuscates your vision!</span>")
	owner.flash_eyes(visual = TRUE)
	..()

/obj/item/organ/internal/eyes/cybernetic/meson
	name = "meson eyes"
	desc = "These cybernetic eyes will allow you to see the structural layout of the station, and, well, everything else."
	eye_color = "#199900"
	vision_flags = SEE_TURFS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	origin_tech = "materials=4;engineering=4;biotech=4;magnets=4"

/obj/item/organ/internal/eyes/cybernetic/xray
	name = "\improper X-ray eyes"
	desc = "These cybernetic eyes will give you X-ray vision. Blinking is futile."
	see_in_dark = 8
	vision_flags = SEE_MOBS | SEE_OBJS | SEE_TURFS
	origin_tech = "materials=4;programming=4;biotech=7;magnets=4"

/obj/item/organ/internal/eyes/cybernetic/thermals
	name = "thermal eyes"
	desc = "These cybernetic eye implants will give you thermal vision. Vertical slit pupil included."
	eye_color = "#FFCC00"
	vision_flags = SEE_MOBS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	flash_protect = FLASH_PROTECTION_SENSITIVE
	see_in_dark = 8
	origin_tech = "materials=5;programming=4;biotech=4;magnets=4;syndicate=1"

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

/obj/item/organ/internal/eyes/cybernetic/shield/emp_act(severity)
	return
