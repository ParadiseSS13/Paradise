/datum/species/shadow/nightmare
	name = "Nightmare"
	name_plural = "Nightmares"

	burn_mod = 1.5
	no_equip = list(slot_wear_mask, slot_wear_suit, slot_gloves, slot_shoes, slot_w_uniform, slot_s_store)
	species_traits = list(NO_BLOOD, NOTRANSSTING)
	inherent_traits = list(TRAIT_RESISTCOLD, TRAIT_NOBREATH, TRAIT_RESISTHIGHPRESSURE, TRAIT_RESISTLOWPRESSURE, TRAIT_CHUNKYFINGERS, TRAIT_RADIMMUNE, TRAIT_VIRUSIMMUNE, TRAIT_PIERCEIMMUNE, TRAIT_NOHUNGER)

	has_organ = list(
		"brain" = /obj/item/organ/internal/brain/nightmare,
		"heart" = /obj/item/organ/internal/heart/nightmare,
		"eyes" = /obj/item/organ/internal/eyes/night_vision/nightmare //8 darksight.
		)

	var/info_text = "You are a <span class='danger'>Nightmare</span>. The ability <span class='warning'>shadow walk</span> allows unlimited, unrestricted movement in the dark while activated. \
					Your <span class='warning'>light eater</span> will destroy any light producing objects you attack, as well as destroy any lights a living creature may be holding. You will automatically dodge gunfire and melee attacks when on a dark tile. If killed, you will eventually revive if left in darkness."

/datum/species/shadow/nightmare/get_random_name(gender)
	return pick(GLOB.nightmare_names)

/datum/species/shadow/nightmare/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	. = ..()
	to_chat(H, "[info_text]")

/datum/species/shadow/nightmare/bullet_act(obj/item/projectile/P, mob/living/carbon/human/H)
	var/turf/T = H.loc
	if(istype(T))
		var/light_amount = T.get_lumcount()
		if(light_amount < SHADOW_SPECIES_LIGHT_THRESHOLD)
			H.visible_message("<span class='danger'>[H] dances in the shadows, evading [P]!</span>")
			playsound(T, "bullet_miss", 75, TRUE)
			return FALSE
	return ..()

//Organs

/obj/item/organ/internal/brain/nightmare
	name = "tumorous mass"
	desc = "A fleshy growth that was dug out of the skull of a Nightmare."
	icon_state = "brain-x-d"
	var/obj/effect/proc_holder/spell/targeted/shadowwalk/shadowwalk

/obj/item/organ/internal/brain/nightmare/insert(mob/living/carbon/human/H, special = FALSE)
	..()
	if(!istype(H))
		return
	if(!isnightmare(H))
		H.set_species(/datum/species/shadow/nightmare)
		visible_message("<span class='warning'>[H] thrashes as [src] takes root in [H.p_their()] body!</span>")
	var/obj/effect/proc_holder/spell/targeted/shadowwalk/SW = new
	H.AddSpell(SW)
	shadowwalk = SW


/obj/item/organ/internal/brain/nightmare/remove(mob/living/carbon/M, special = FALSE)
	if(shadowwalk)
		M.RemoveSpell(shadowwalk)
	return ..()

/// How many life ticks are required for the nightmare's heart to revive the nightmare.
#define HEART_RESPAWN_THRESHHOLD 40
/// A special flag value used to make a nightmare heart not grant a light eater. Appears to be unused.
#define HEART_SPECIAL_SHADOWIFY 2

/obj/item/organ/internal/heart/nightmare
	name = "heart of darkness"
	desc = "An alien organ that twists and writhes when exposed to light."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "demon_heart-on"
	color = "#1C1C1C"
	var/respawn_progress = 0
	var/obj/item/light_eater/blade

/obj/item/organ/internal/heart/nightmare/update_icon()
	return //always beating visually

/obj/item/organ/internal/heart/nightmare/attack(mob/M, mob/living/carbon/user, obj/target)
	if(M != user)
		return ..()
	user.visible_message("<span class='warning'>[user] raises [src] to [user.p_their()] mouth and tears into it with [user.p_their()] teeth!</span>", \
		"<span class='danger'>[src] feels unnaturally cold in your hands. You raise [src] your mouth and devour it!</span>")
	playsound(user, 'sound/magic/demon_consume.ogg', 50, TRUE)


	user.visible_message("<span class='warning'>Blood erupts from [user]'s arm as it reforms into a weapon!</span>", \
		"<span class='userdanger'>Icy blood pumps through your veins as your arm reforms itself!</span>")
	user.unEquip(src, TRUE)
	insert(user)

/obj/item/organ/internal/heart/nightmare/insert(mob/living/carbon/M, special = FALSE)
	..()
	if(special != HEART_SPECIAL_SHADOWIFY)
		blade = new/obj/item/light_eater
		M.put_in_hands(blade)
	START_PROCESSING(SSobj, src)

/obj/item/organ/internal/heart/nightmare/remove(mob/living/carbon/M, special = FALSE)
	. = ..()
	STOP_PROCESSING(SSobj, src)
	respawn_progress = 0
	if(blade && special != HEART_SPECIAL_SHADOWIFY)
		M.visible_message("<span class='warning'>\The [blade] disintegrates!</span>")
		QDEL_NULL(blade)

/obj/item/organ/internal/heart/nightmare/Stop()
	return FALSE

/obj/item/organ/internal/heart/nightmare/process()
	if(QDELETED(owner) || !ishuman(owner) || owner.stat != DEAD)
		respawn_progress = 0
		return
	var/turf/T = get_turf(owner)
	if(istype(T))
		var/light_amount = T.get_lumcount()
		if(light_amount < SHADOW_SPECIES_LIGHT_THRESHOLD)
			respawn_progress++
			playsound(owner,'sound/effects/singlebeat.ogg', 40, TRUE)
	if(respawn_progress >= HEART_RESPAWN_THRESHHOLD)
		owner.revive()
		if(!(isshadowperson(owner) || isnightmare(owner)))
			var/mob/living/carbon/human/old_owner = owner
			remove(owner, HEART_SPECIAL_SHADOWIFY)
			old_owner.set_species(/datum/species/shadow)
			insert(old_owner, HEART_SPECIAL_SHADOWIFY)
			to_chat(owner, "<span class='userdanger'>You feel the shadows invade your skin, leaping into the center of your chest! You're alive!</span>")
			SEND_SOUND(owner, sound('sound/effects/ghost.ogg'))
		owner.visible_message("<span class='warning'>[owner] staggers to [owner.p_their()] feet!</span>")
		playsound(owner, 'sound/hallucinations/far_noise.ogg', 50, TRUE)
		respawn_progress = 0

//Weapon

/obj/item/light_eater
	name = "light eater" //as opposed to heavy eater
	icon_state = "arm_blade"
	item_state = "arm_blade"
	force = 25
	armour_penetration = 35
	flags = ABSTRACT | DROPDEL | ACID_PROOF | NODROP
	w_class = WEIGHT_CLASS_HUGE
	sharp = TRUE
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/light_eater/afterattack(atom/movable/AM, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(isfloorturf(AM) || isspaceturf(AM)) //So you can actually melee with it
		return

	if(isliving(AM))
		var/mob/living/L = AM

		if(isrobot(AM))
			var/mob/living/silicon/robot/borg = AM
			if(borg.lamp_intensity)
				borg.update_headlamp(TRUE, INFINITY)
				to_chat(borg, "<span class='danger'>Your headlamp is fried! You'll need a human to help replace it.</span>")
		else
			for(var/obj/item/O in L.GetAllContents())
				light_item_check(O, L)
		if(L.pulling)
			light_item_check(L.pulling, L.pulling)

	else if(isitem(AM))
		light_item_check(AM, AM)


	else if(ismecha(AM))
		var/obj/mecha/M = AM
		if(M.haslights)
			M.visible_message("<span class='danger'>[M]'s lights burn out!</span>")
			M.haslights = FALSE
		M.set_light(-M.lights_power)
		if(M.occupant)
			M.lights_action.Remove(M.occupant)
		for(var/obj/item/O in AM.GetAllContents())
			if(O.light_range && O.light_power)
				disintegrate(O, M)

	else if(istype(AM, /obj/machinery/light))
		var/obj/machinery/light/L = AM
		if(L.status == 1)
			return
		disintegrate(L.drop_light_tube(), L)

///checks if the item has an active light, and destroy the light source if it does.
/obj/item/light_eater/proc/light_item_check(obj/item/I, atom/A)
	if(!isitem(I))
		return
	if(I.light_range && I.light_power)
		disintegrate(I, A)
	else if(istype(I, /obj/item/gun))
		var/obj/item/gun/G = I
		if(G.gun_light?.on)
			disintegrate(G.gun_light, A)

/obj/item/light_eater/proc/disintegrate(obj/item/O, atom/A)
	if(istype(O, /obj/item/pda))
		var/obj/item/pda/PDA = O
		var/datum/data/pda/utility/flashlight/F = PDA.find_program(/datum/data/pda/utility/flashlight)
		F.f_lum = 0
		F.start()
		A.visible_message("<span class='danger'>The light in [PDA] shorts out!</span>")
	else
		A.visible_message("<span class='danger'>[O] is disintegrated by [src]!</span>")
		O.burn()
	playsound(src, 'sound/items/welder.ogg', 50, TRUE)

#undef HEART_SPECIAL_SHADOWIFY
#undef HEART_RESPAWN_THRESHHOLD
