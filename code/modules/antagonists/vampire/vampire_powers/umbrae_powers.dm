/obj/effect/proc_holder/spell/vampire/self/cloak
	name = "Cloak of Darkness"
	desc = "Toggles whether you are currently cloaking yourself in darkness. When in darkness and toggled on, you move at increased speeds."
	gain_desc = "You have gained the Cloak of Darkness ability, which when toggled makes you nearly invisible and highly agile in the shroud of darkness."
	action_icon_state = "vampire_cloak"
	charge_max = 2 SECONDS

/obj/effect/proc_holder/spell/vampire/self/cloak/New()
	..()
	update_name()

/obj/effect/proc_holder/spell/vampire/self/cloak/proc/update_name()
	var/mob/living/user = loc
	if(!ishuman(user) || !user.mind)
		return
	var/datum/antagonist/vampire/V = user.mind.has_antag_datum(/datum/antagonist/vampire)
	if(!V)
		return
	action.button.name = "[initial(name)] ([V.iscloaking ? "Deactivate" : "Activate"])"

/obj/effect/proc_holder/spell/vampire/self/cloak/cast(list/targets, mob/user = usr)
	var/datum/antagonist/vampire/V = user.mind.has_antag_datum(/datum/antagonist/vampire)
	V.iscloaking = !V.iscloaking
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(V.iscloaking)
			H.physiology.burn_mod *= 1.3
			user.RegisterSignal(user, COMSIG_LIVING_IGNITED, /mob/living.proc/update_vampire_cloak)
		else
			user.UnregisterSignal(user, COMSIG_LIVING_IGNITED)
			H.physiology.burn_mod /= 1.3

	update_name()
	to_chat(user, "<span class='notice'>You will now be [V.iscloaking ? "hidden" : "seen"] in darkness.</span>")

/mob/living/proc/update_vampire_cloak()
	SIGNAL_HANDLER
	var/datum/antagonist/vampire/V = mind.has_antag_datum(/datum/antagonist/vampire)
	V.handle_vampire_cloak()

/obj/effect/proc_holder/spell/vampire/shadow_snare
	name = "Shadow Snare (20)"
	desc = "You summon a trap on the ground. When crossed it will blind the target, extinguish any lights they may have, and ensnare them."
	gain_desc = "You have gained the ability to summon a trap that will blind, ensnare, and turn off the lights of anyone who crosses it."
	charge_max = 20 SECONDS
	required_blood = 20
	action_icon_state = "shadow_snare"

/obj/effect/proc_holder/spell/vampire/shadow_snare/create_new_targeting()
	var/datum/spell_targeting/click/T = new
	T.allowed_type = /turf/simulated
	T.click_radius = -1
	return T

/obj/effect/proc_holder/spell/vampire/shadow_snare/cast(list/targets, mob/user)
	var/turf/target = targets[1]
	new /obj/item/restraints/legcuffs/beartrap/shadow_snare(target)

/obj/item/restraints/legcuffs/beartrap/shadow_snare
	name = "shadow snare"
	desc = "An almost transparent trap that melts into the shadows."
	alpha = 60
	armed = TRUE
	anchored = TRUE
	breakouttime = 5 SECONDS
	flags = DROPDEL

/obj/item/restraints/legcuffs/beartrap/shadow_snare/Crossed(AM, oldloc)
	if(!iscarbon(AM) || !armed)
		return
	var/mob/living/carbon/C = AM
	if(!C.affects_vampire()) // no parameter here so holy always protects
		return
	C.extinguish_light()
	C.EyeBlind(10)
	STOP_PROCESSING(SSobj, src) // won't wither away once you are trapped
	..()
	if(!iscarbon(loc)) // if it fails to latch onto someone for whatever reason, delete itself, we don't want unarmed ones lying around.
		qdel(src)

/obj/item/restraints/legcuffs/beartrap/shadow_snare/attack_hand(mob/user)
	Crossed(user)

/obj/item/restraints/legcuffs/beartrap/shadow_snare/attack_tk(mob/user)
	if(iscarbon(user))
		to_chat(user, "<span class='userdanger'>The snare sends a psychic backlash!</span>")
		user.EyeBlind(10)

/obj/item/restraints/legcuffs/beartrap/shadow_snare/process()
	var/turf/T = get_turf(src)
	var/lighting_count = T.get_lumcount() * 10
	if(lighting_count > 2)
		obj_integrity -= 50

	if(obj_integrity <= 0)
		visible_message("<span class='notice'>[src] withers away.</span>")
		qdel(src)

/obj/item/restraints/legcuffs/beartrap/shadow_snare/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/restraints/legcuffs/beartrap/shadow_snare/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/proc_holder/spell/vampire/dark_passage
	name = "Dark Passage (30)"
	desc = "You teleport to a targeted turf."
	gain_desc = "You have gained the ability to blink a short distance towards a targeted turf."
	charge_max = 40 SECONDS
	required_blood = 30
	centcom_cancast = FALSE
	action_icon_state = "dark_passage"

/obj/effect/proc_holder/spell/vampire/dark_passage/create_new_targeting()
	var/datum/spell_targeting/click/T = new
	T.click_radius = 0
	T.allowed_type = /turf/simulated
	return T

/obj/effect/proc_holder/spell/vampire/dark_passage/cast(list/targets, mob/user)
	var/turf/target = get_turf(targets[1])

	new /obj/effect/temp_visual/vamp_mist_out(get_turf(user))

	user.forceMove(target)

/obj/effect/temp_visual/vamp_mist_out
	duration = 2 SECONDS
	icon = 'icons/mob/mob.dmi'
	icon_state = "mist"

/obj/effect/proc_holder/spell/vampire/vamp_extinguish
	name = "Extinguish"
	desc = "You extinguish any light source in an area around you."
	gain_desc = "You have gained the ability to extinguish nearby light sources."
	charge_max = 20 SECONDS
	action_icon_state = "vampire_extinguish"
	create_attack_logs = FALSE
	create_custom_logs = TRUE

/obj/effect/proc_holder/spell/vampire/vamp_extinguish/create_new_targeting()
	var/datum/spell_targeting/aoe/turf/T = new
	return T

/obj/effect/proc_holder/spell/vampire/vamp_extinguish/cast(list/targets, mob/user = usr)
	for(var/turf/T in targets)
		T.extinguish_light()
		for(var/atom/A in T.contents)
			A.extinguish_light()

/obj/effect/proc_holder/spell/vampire/self/eternal_darkness
	name = "Eternal Darkness"
	desc = "When toggled, you shroud the area around you in darkness and slowly lower the body temperature of people nearby."
	gain_desc = "You have gained the ability to shroud the area around you in darkness, only the strongest of lights can pierce your unholy powers."
	charge_max = 10 SECONDS
	action_icon_state = "eternal_darkness"
	required_blood = 5
	var/shroud_power = -4

/obj/effect/proc_holder/spell/vampire/self/eternal_darkness/cast(list/targets, mob/user)
	var/datum/antagonist/vampire/V = user.mind.has_antag_datum(/datum/antagonist/vampire)
	var/mob/target = targets[1]
	if(!V.get_ability(/datum/vampire_passive/eternal_darkness))
		V.force_add_ability(/datum/vampire_passive/eternal_darkness)
		target.set_light(6, shroud_power, "#AAD84B")
	else
		for(var/datum/vampire_passive/eternal_darkness/E in V.powers)
			V.remove_ability(E)

/datum/vampire_passive/eternal_darkness
	gain_desc = "You surround yourself in a unnatural darkness, freezing those around you."

/datum/vampire_passive/eternal_darkness/New()
	..()
	START_PROCESSING(SSobj, src)

/datum/vampire_passive/eternal_darkness/Destroy(force, ...)
	owner.remove_light()
	STOP_PROCESSING(SSobj, src)
	return ..()

/datum/vampire_passive/eternal_darkness/process()
	var/datum/antagonist/vampire/V = owner.mind.has_antag_datum(/datum/antagonist/vampire)

	for(var/mob/living/L in view(6, owner))
		if(L.affects_vampire(owner))
			L.adjust_bodytemperature(-20 * TEMPERATURE_DAMAGE_COEFFICIENT)

	V.bloodusable = max(V.bloodusable - 5, 0)

	if(!V.bloodusable || owner.stat == DEAD)
		V.remove_ability(src)

/datum/vampire_passive/xray
	gain_desc = "You can now see through walls, incase you hadn't noticed."
