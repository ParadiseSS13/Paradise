#define INFINITE -1

/obj/item/autosurgeon
	name = "autosurgeon"
	desc = "A device that automatically inserts an implant or organ into the user without the hassle of extensive surgery. It has a screwdriver slot for removing accidentally added items."
	icon = 'icons/obj/device.dmi'
	icon_state = "autoimplanter"
	w_class = WEIGHT_CLASS_SMALL
	var/uses = INFINITE

/obj/item/autosurgeon/attack_self_tk(mob/user)
	return //stops TK fuckery

/obj/item/autosurgeon/organ
	name = "implant autosurgeon"
	desc = "A device that automatically inserts an implant or organ into the user without the hassle of extensive surgery. It has a slot to insert implants or organs and a screwdriver slot for removing accidentally added items."
	var/organ_type = /obj/item/organ/internal
	var/starting_organ
	var/obj/item/organ/internal/storedorgan

/obj/item/autosurgeon/organ/Initialize(mapload)
	. = ..()
	if(starting_organ)
		insert_organ(new starting_organ(src))

/obj/item/autosurgeon/organ/proc/insert_organ(obj/item/I)
	storedorgan = I
	I.forceMove(src)
	name = "[initial(name)] ([storedorgan.name])"

/obj/item/autosurgeon/organ/attack_self__legacy__attackchain(mob/user) //when the object it used...
	if(!uses)
		to_chat(user, "<span class='alert'>[src] has already been used. The tools are dull and won't reactivate.</span>")
		return
	else if(!storedorgan)
		to_chat(user, "<span class='alert'>[src] currently has no implant stored.</span>")
		return
	SSblackbox.record_feedback("tally", "o_implant_auto", 1, "[storedorgan.type]")
	storedorgan.insert(user) //insert stored organ into the user
	user.visible_message("<span class='notice'>[user] presses a button on [src], and you hear a short mechanical noise.</span>", "<span class='notice'>You feel a sharp sting as [src] plunges into your body.</span>")
	playsound(get_turf(user), 'sound/weapons/circsawhit.ogg', 50, TRUE)
	storedorgan = null
	name = initial(name)
	if(uses != INFINITE)
		uses--
	if(!uses)
		desc = "[initial(desc)] Looks like it's been used up."

/obj/item/autosurgeon/organ/attackby__legacy__attackchain(obj/item/I, mob/user, params)
	if(istype(I, organ_type))
		if(storedorgan)
			to_chat(user, "<span class='alert'>[src] already has an implant stored.</span>")
			return
		else if(!uses)
			to_chat(user, "<span class='alert'>[src] has already been used up.</span>")
			return
		if(!user.drop_item())
			return
		I.forceMove(src)
		storedorgan = I
		to_chat(user, "<span class='notice'>You insert [I] into [src].</span>")
	else
		return ..()

/obj/item/autosurgeon/organ/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(!storedorgan)
		to_chat(user, "<span class='warning'>There's no implant in [src] for you to remove!</span>")
	else
		storedorgan.forceMove(user.drop_location())

		to_chat(user, "<span class='notice'>You remove [storedorgan] from [src].</span>")
		I.play_tool_sound(src)
		storedorgan = null
		if(uses != INFINITE)
			uses--
		if(!uses)
			desc = "[initial(desc)] Looks like it's been used up."
	return TRUE

/obj/item/autosurgeon/organ/one_use
	uses = 1

/obj/item/autosurgeon/organ/one_use/skill_hud
	desc = "A single use autosurgeon that contains a skill heads up display. A screwdriver can be used to remove it, but implants can't be placed back in."
	starting_organ = /obj/item/organ/internal/cyberimp/eyes/hud/skill

/obj/item/autosurgeon/organ/one_use/sec_hud
	desc = "A single use autosurgeon that contains a security heads up display. A screwdriver can be used to remove it, but implants can't be placed back in."
	starting_organ = /obj/item/organ/internal/cyberimp/eyes/hud/security

/obj/item/autosurgeon/organ/one_use/med_hud
	desc = "A single use autosurgeon that contains a medical heads up display. A screwdriver can be used to remove it, but implants can't be placed back in."
	starting_organ = /obj/item/organ/internal/cyberimp/eyes/hud/medical

/obj/item/autosurgeon/organ/one_use/diagnostic_hud
	desc = "A single use autosurgeon that contains a diagnostic heads up display. A screwdriver can be used to remove it, but implants can't be placed back in."
	starting_organ = /obj/item/organ/internal/cyberimp/eyes/hud/diagnostic

/obj/item/autosurgeon/organ/one_use/wire_interface
	desc = "A single use autosurgeon that contains a wire interface. A screwdriver can be used to remove it, but implants can't be placed back in."
	starting_organ = /obj/item/organ/internal/cyberimp/brain/wire_interface

/obj/item/autosurgeon/organ/one_use/meson_eyes
	desc = "A single use autosurgeon that contains a set of meson eyes. A screwdriver can be used to remove it, but implants can't be placed back in."
	starting_organ = /obj/item/organ/internal/eyes/cybernetic/meson

/obj/item/autosurgeon/organ/syndicate
	name = "suspicious implant autosurgeon"
	icon_state = "syndicate_autoimplanter"

/obj/item/autosurgeon/organ/syndicate/attack_self__legacy__attackchain(mob/user)
	if(storedorgan && uses && storedorgan.is_robotic()) // Helps keep the syndicate ones hidden. One can peel them off if they want them to be visable.
		storedorgan.self_augmented_skin_level = 3
	return ..()

/obj/item/autosurgeon/organ/syndicate/oneuse
	uses = 1

/obj/item/autosurgeon/organ/syndicate/oneuse/laser_arm
	desc = "A single use autosurgeon that contains a combat arms-up laser augment. A screwdriver can be used to remove it, but implants can't be placed back in."
	starting_organ = /obj/item/organ/internal/cyberimp/arm/gun/laser

/obj/item/autosurgeon/organ/syndicate/oneuse/meson_eyes
	desc = "A single use autosurgeon that contains a pair of cybernetic meson eyes. A screwdriver can be used to remove it, but implants can't be placed back in."
	starting_organ = /obj/item/organ/internal/eyes/cybernetic/meson

/obj/item/autosurgeon/organ/syndicate/oneuse/razorwire
	desc = "A single use autosurgeon that contains a Razorwire arm implant. A screwdriver can be used to remove it, but implants can't be placed back in."
	starting_organ = /obj/item/organ/internal/cyberimp/arm/razorwire

/obj/item/autosurgeon/organ/syndicate/oneuse/razorwire/examine_more(mob/user)
	. = ..()
	if(storedorgan)
		return storedorgan.examine_more()

/obj/item/autosurgeon/organ/syndicate/oneuse/hackerman_deck
	desc = "A single use autosurgeon that contains a Binyat wireless hacking system. A screwdriver can be used to remove it, but implants can't be placed back in."
	starting_organ = /obj/item/organ/internal/cyberimp/brain/hackerman_deck

/obj/item/autosurgeon/organ/syndicate/oneuse/hackerman_deck/examine_more(mob/user)
	. = ..()
	. += "<i>Considered Cybersun Incorporated's most recent and developed implant system focused on hacking from a range while being undetectable from normal means. \
	The Binyat Wireless Hacking System (BWHS) is a stealth-built implant that gives its user a rudimentary electronic interface on whatever can be perceived. \
	It uses a micro jammer to hide its existence from even the most advanced scanning systems.<i>"
	. += "<i>Originally designed as a hand-held device for long-range testing of Cybersun's electronic security systems, \
	the easy integration of the components into a neural implant led to a revaluation of the device's potential. \
	Development would commence to create the first sets of prototypes,  focusing on tricking scanners with no false positives, \
	and being able to hack from afar. The System does have a major flaw, however, as Cybersun R&D was never able to miniaturize its cooling systems to a practical level. \
	Repeated use will lead to skin irritation, internal burns, and even severe nerve damage in extreme cases.<i>"
	. += "<i>As of modern times, the BWHS is heavily vetted under Cybersun Inc. due to its dangerous nature and rather difficult detection. \
	However, this hasn't stopped the flow of these implants from reaching the black market, whether by inside or outside influences.</i>"

/obj/item/autosurgeon/organ/syndicate/oneuse/sensory_enhancer
	desc = "A single use autosurgeon that contains a Qani-Laaca sensory computer. A screwdriver can be used to remove it, but implants can't be placed back in."
	starting_organ = /obj/item/organ/internal/cyberimp/brain/sensory_enhancer

/obj/item/autosurgeon/organ/syndicate/oneuse/sensory_enhancer/examine(mob/user)
	. = ..()
	. += "<span class='userdanger'>Epilepsy Warning: Drug has vibrant visual effects!</span>"

/obj/item/autosurgeon/organ/syndicate/oneuse/sensory_enhancer/examine_more(mob/user)
	. = ..()
	if(storedorgan)
		return storedorgan.examine_more()

/obj/item/autosurgeon/organ/syndicate/oneuse/scope_eyes
	desc = "A single use autosurgeon that contains Hardened Kaleido Optics eyes. A screwdriver can be used to remove it, but implants can't be placed back in."
	starting_organ = /obj/item/organ/internal/eyes/cybernetic/scope/hardened

/obj/item/autosurgeon/organ/syndicate/thermal_eyes
	starting_organ = /obj/item/organ/internal/eyes/cybernetic/thermals/hardened

/obj/item/autosurgeon/organ/syndicate/xray_eyes
	starting_organ = /obj/item/organ/internal/eyes/cybernetic/xray/hardened

/obj/item/autosurgeon/organ/syndicate/anti_stam
	starting_organ = /obj/item/organ/internal/cyberimp/brain/anti_stam/hardened

/obj/item/autosurgeon/organ/syndicate/reviver
	starting_organ = /obj/item/organ/internal/cyberimp/chest/reviver/hardened

/obj/item/autosurgeon/organ/syndicate/oneuse/hardened_heart
	starting_organ = /obj/item/organ/internal/heart/cybernetic/upgraded/hardened

/obj/item/autosurgeon/organ/syndicate/oneuse/syndie_mantis
	starting_organ = /obj/item/organ/internal/cyberimp/arm/syndie_mantis

/obj/item/autosurgeon/organ/syndicate/oneuse/syndie_mantis/l
	starting_organ = /obj/item/organ/internal/cyberimp/arm/syndie_mantis/l

#undef INFINITE
