/obj/item/organ_extractor
	name = "organ extractor"
	desc = "A device that can remove organs from a target, and store them inside. Stored organs can be implanted into the user. Synthesizes chemicals to keep the organ fresh."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "organ_extractor"
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "biotech=6;materials=5;syndicate=2"
	var/obj/item/organ/internal/storedorgan
	var/insert_time = 12 SECONDS
	var/self_insert_time = 7 SECONDS
	var/advanced = FALSE

/obj/item/organ_extractor/examine(mob/user)
	. = ..()
	if(storedorgan)
		. += "<span class='notice'>It has [storedorgan] floating around inside the jar!</span>"
		. += "<span class='notice'>You can <b>Screwdriver</b> [src] to try to adjust [storedorgan]'s configuration.</span>"
		. += "<span class='notice'>You can <b>Wrench</b> [src] to eject [storedorgan]!</span>"

/obj/item/organ_extractor/screwdriver_act(mob/living/user, obj/item/I)
	if(storedorgan)
		return storedorgan.screwdriver_act(user, I)

/obj/item/organ_extractor/wrench_act(mob/living/user, obj/item/I)
	if(storedorgan)
		to_chat(user, "<span class='warning'>You unwrench the jar, and [storedorgan] falls onto the floor!</span>")
		storedorgan.forceMove(get_turf(user))
		storedorgan = null
		playsound(src, 'sound/effects/splat.ogg', 50, TRUE)
		overlays.Cut()
		return TRUE

/obj/item/organ_extractor/emag_act(mob/user)
	if(storedorgan)
		storedorgan.emag_act(user)

/obj/item/organ_extractor/emp_act(severity)
	if(storedorgan)
		storedorgan.emp_act(severity)

/obj/item/organ_extractor/attack_self__legacy__attackchain(mob/user)
	insert_organ(user, user)

/obj/item/organ_extractor/attack__legacy__attackchain(mob/living/M, mob/living/user, def_zone)
	if(in_use)
		to_chat(user, "<span class='warning'>[src] is already busy!</span>")
		return
	if(!iscarbon(M))
		to_chat(user, "<span class='warning'>ERROR: [M] has no organs to harvest!</span>")
		return

	var/mob/living/carbon/C = M
	if(!length(C.client_mobs_in_contents)) //Basically, we don't want someone putting organs in monkeys then extracting from it. Has to be someone who had a client in the past
		to_chat(user, "<span class='warning'>ERROR: [C] has no soul trace to assist in targeting the drill bit!</span>")
		return
	if(!IS_HORIZONTAL(C) && C.stat == CONSCIOUS)
		to_chat(user, "<span class='warning'>ERROR: [C] is not restrained, and may move during the operation! Correction required.</span>")
		return
	if(storedorgan)
		to_chat(user, "<span class='warning'>NOTICE: Internal organ deteced. Beginning insertion procedure!</span>")
		insert_organ(user, C)
		return

	in_use = TRUE
	var/obj/item/chosen_organ = tgui_input_list(user, "Please select an organ for removal", "Organ Selection", C.internal_organs)
	if(!chosen_organ || !user.Adjacent(C))
		in_use = FALSE
		return
	if(!istype(chosen_organ, /obj/item/organ/internal)) //Saftey first
		to_chat(user, "<span class='warning'>ERROR: [chosen_organ] is not valid for removal for unknown reasons!</span>")
		in_use = FALSE
		return
	if(istype(chosen_organ, /obj/item/organ/internal/brain/mmi_holder)) //This breaks shit
		to_chat(user, "<span class='warning'>ERROR: [chosen_organ] is too big for the holding tank and would damage [src] too much!</span>")
		in_use = FALSE
		return
	if(HAS_TRAIT(chosen_organ, TRAIT_ORGAN_INSERTED_WHILE_DEAD))
		to_chat(user, "<span class='warning'>ERROR: [chosen_organ] was inserted when [C] was dead, and has no soul trace to lock onto!</span>")
		in_use = FALSE
		return

	var/obj/item/organ/internal/internal_organ = chosen_organ
	var/drilled_organ = internal_organ.parent_organ
	user.visible_message("<span class='danger'>[user] activates [src] and begins to drill into [C]!</span>", "<span class='warning'>You level the extractor at [M] and hold down the trigger.</span>")
	to_chat(C, "<span class='danger'>You feel a lot of pain as [user] drills into your [drilled_organ]!</span>")
	playsound(get_turf(user), 'sound/weapons/circsawhit.ogg', 75, TRUE)

	if(!advanced)
		C.apply_damage(15, BRUTE, drilled_organ)
	if(!do_after_once(user, insert_time, target = C))// Slightly longer than stamina crit, at least cuff and buckle them to a pipe or something
		to_chat(user, "<span class='warning'>ERROR: Process interrupted!</span>")
		in_use = FALSE
		return
	if(!internal_organ || !istype(internal_organ) || !(internal_organ.owner == C)) //Organ got deleted / moved somewhere else?
		to_chat(user, "<span class='warning'>ERROR: unable to find the desired organ!</span>")
		in_use = FALSE
		return

	user.visible_message("<span class='danger'>[user] removes [internal_organ] from [C]!</span>", "<span class='warning'>You remove [internal_organ] from [C] as it gets sucked into [src]'s internal container!</span>")
	playsound(get_turf(user), 'sound/weapons/circsawhit.ogg', 75, TRUE)
	C.apply_damage(10, BRUTE, drilled_organ)
	internal_organ.remove(C)
	in_use = FALSE
	insert_internal_organ_in_extractor(internal_organ)

/obj/item/organ_extractor/proc/insert_organ(mob/user, mob/our_target)
	if(!storedorgan)
		to_chat(user, "<span class='warning'>[src] currently has no organ stored.</span>")
		return
	if(in_use)
		to_chat(user, "<span class='warning'>[src] is already busy!</span>")
		return

	var/user_is_target = FALSE
	if(user == our_target)
		user_is_target = TRUE
	if(istype(storedorgan, /obj/item/organ/internal/brain) && user_is_target)
		to_chat(user, "<span class='warning'>It would be really stupid to replace your brain with another one.</span>")
		return
	if(!iscarbon(our_target))
		return

	var/mob/living/carbon/C = our_target
	in_use = TRUE
	user.visible_message("<span class='danger'>[user] activates [src] and begins to drill into [C]!</span>", "<span class='warning'>You level the extractor at [user_is_target ? "yourself" : C] and hold down the trigger.</span>")
	var/drilled_organ = storedorgan.parent_organ
	if(!advanced)
		C.apply_damage(5, BRUTE, drilled_organ)
	playsound(get_turf(C), 'sound/weapons/circsawhit.ogg', 50, TRUE)

	if(!do_after_once(user, (user_is_target ? self_insert_time : insert_time), target = C))
		to_chat(user, "<span class='warning'>ERROR: Process interrupted!</span>")
		in_use = FALSE
		return

	if(!advanced)
		C.apply_damage(10, BRUTE, drilled_organ)
	var/obj/item/organ/internal/replaced = C.get_organ_slot(storedorgan.slot)
	if(replaced) //Lets not destroy someones brain fully by putting someone elses brain in that slot.
		replaced.remove(C)
		replaced.forceMove(get_turf(src))
		if(istype(storedorgan, /obj/item/organ/internal/heart) && ((/obj/item/organ/internal/cyberimp/brain/sensory_enhancer in C.internal_organs) || C.reagents.addiction_threshold_accumulated[/datum/reagent/mephedrone]))
			storedorgan.damage = 40 // Damage the heart so you can't endlessly OD for cheap easily.
			to_chat(user, "<span class='warning'>CAUTION: Crystalized mephedrone has bounced off the drill into [storedorgan], causing internal damage!</span>")
	SSblackbox.record_feedback("tally", "o_implant_extract", 1, "[storedorgan.type]")
	storedorgan.insert(C)
	playsound(get_turf(C), 'sound/weapons/circsawhit.ogg', 50, TRUE)
	storedorgan = null
	in_use = FALSE
	overlays.Cut()
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		H.set_heartattack(FALSE) //Otherwise you die if you try to do an organic heart, very funny, very bad

/obj/item/organ_extractor/proc/insert_internal_organ_in_extractor(obj/item/organ/organ_to_be_inserted)
	organ_to_be_inserted.forceMove(src)
	storedorgan = organ_to_be_inserted
	storedorgan.rejuvenate() //Organ gets dumped into the internal mito tank, heals it up. And nanites for robotic organs, I guess.
	var/organ_x = storedorgan.pixel_x
	var/organ_y = storedorgan.pixel_y
	storedorgan.pixel_x = 2
	storedorgan.pixel_y = -2
	var/image/img = image("icon" = storedorgan, "layer" = FLOAT_LAYER)
	var/matrix/MA = matrix(transform)
	MA.Scale(0.66, 0.66)
	img.transform = MA
	img.plane = FLOAT_PLANE
	overlays += img
	storedorgan.pixel_x = organ_x
	storedorgan.pixel_y = organ_y
	overlays += "[icon_state]_2" //should look nicer for transparent stuff.

/// Advanced abductor version. Is a lot faster with implanting into others
/obj/item/organ_extractor/abductor
	name = "alien organ extractor"
	origin_tech = "biotech=6;materials=5;abductor=4"
	icon_state = "abductor_extractor"
	insert_time = 3 SECONDS
	self_insert_time = 1 SECONDS
	advanced = TRUE

/obj/item/organ_extractor/abductor/attackby__legacy__attackchain(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/organ/internal) && !storedorgan)
		user.unequip(I)
		insert_internal_organ_in_extractor(I)

/obj/item/organ_extractor/abductor/emp_act(severity)
	return FALSE
