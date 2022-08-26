/obj/effect/proc_holder/spell/vampire/self/blood_swell
	name = "Blood Swell (30)"
	desc = "You infuse your body with blood, making you highly resistant to stuns and physical damage. However, this makes you unable to fire ranged weapons while it is active."
	gain_desc = "You have gained the ability to temporarly resist large amounts of stuns and physical damage."
	base_cooldown = 40 SECONDS
	required_blood = 30
	action_icon_state = "blood_swell"

/obj/effect/proc_holder/spell/vampire/self/blood_swell/cast(list/targets, mob/user)
	var/mob/living/target = targets[1]
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.apply_status_effect(STATUS_EFFECT_BLOOD_SWELL)

/obj/effect/proc_holder/spell/vampire/self/stomp
	name = "Siesmic Stomp"
	desc = "You slam your foot into the ground sending a powerful shockwave through the stations hull, sending people flying away."
	gain_desc = "You have gained the ability to send a knock people back using a powerful stomp."
	base_cooldown = 60 SECONDS
	required_blood = 30
	var/max_range = 4

/obj/effect/proc_holder/spell/vampire/self/stomp/cast(list/targets, mob/user)
	var/turf/T = get_turf(user)
	playsound(T, 'sound/effects/meteorimpact.ogg', 100, TRUE)
	hit_check(1, T, user)
	new /obj/effect/temp_visual/stomp(T)

/obj/effect/proc_holder/spell/vampire/self/stomp/proc/hit_check(range, turf/start_turf, mob/user, safe_targets = list())
	for(var/mob/living/L in view(range, start_turf) - view(range - 1, start_turf))
		if(L in safe_targets)
			continue
		if(L.throwing) // no double hits
			continue
		if(!L.affects_vampire(user))
			continue
		if(L.move_resist > MOVE_FORCE_VERY_STRONG)
			continue
		var/throw_target = get_edge_target_turf(L, get_dir(start_turf, L))
		INVOKE_ASYNC(L, /atom/movable/.proc/throw_at, throw_target, 3, 4)
		L.KnockDown(1 SECONDS)
		safe_targets += L
	var/new_range = range + 1
	if(new_range <= max_range)
		addtimer(CALLBACK(src, .proc/hit_check, new_range, start_turf, user, safe_targets), 0.2 SECONDS)

/obj/effect/temp_visual/stomp
	icon = 'icons/effects/vampire_effects.dmi'
	icon_state = "stomp_effect"
	duration = 0.8 SECONDS

/obj/effect/temp_visual/stomp/Initialize(mapload)
	. = ..()
	animate(src, transform = matrix() * 8, time = duration, alpha = 0)

/datum/vampire_passive/blood_swell_upgrade
	gain_desc = "While blood swell is active all of your melee attacks deal increased damage."

/obj/effect/proc_holder/spell/vampire/self/overwhelming_force
	name = "Overwhelming Force"
	desc = "When toggled you will automatically pry open doors that you bump into if you do not have access."
	gain_desc = "You have gained the ability to force open doors at a small blood cost."
	base_cooldown = 2 SECONDS
	action_icon_state = "OH_YEAAAAH"

/obj/effect/proc_holder/spell/vampire/self/overwhelming_force/cast(list/targets, mob/user)
	if(!HAS_TRAIT_FROM(user, TRAIT_FORCE_DOORS, VAMPIRE_TRAIT))
		to_chat(user, "<span class='warning'>You feel MIGHTY!</span>")
		ADD_TRAIT(user, TRAIT_FORCE_DOORS, VAMPIRE_TRAIT)
		user.status_flags &= ~CANPUSH
		user.move_resist = MOVE_FORCE_STRONG
	else
		REMOVE_TRAIT(user, TRAIT_FORCE_DOORS, VAMPIRE_TRAIT)
		user.move_resist = MOVE_FORCE_DEFAULT
		user.status_flags |= CANPUSH

/obj/effect/proc_holder/spell/vampire/self/blood_rush
	name = "Blood Rush (30)"
	desc = "Infuse yourself with blood magic to boost your movement speed."
	gain_desc = "You have gained the ability to temporarily move at high speeds."
	base_cooldown = 30 SECONDS
	required_blood = 30
	action_icon_state = "blood_rush"

/obj/effect/proc_holder/spell/vampire/self/blood_rush/cast(list/targets, mob/user)
	var/mob/living/target = targets[1]
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		to_chat(H, "<span class='notice'>You feel a rush of energy!</span>")
		H.apply_status_effect(STATUS_EFFECT_BLOOD_RUSH)

/obj/effect/proc_holder/spell/vampire/vampiric_deprival
	name = "Vampiric Deprival (50)"
	desc = "Weaken your target and buff up yourself."
	gain_desc = "You have gained the ability to temporarily drain a target of their resistance to damage and increase your own."
	human_req = TRUE
	base_cooldown = 1 MINUTES
	required_blood = 50

/obj/effect/proc_holder/spell/vampire/vampiric_deprival/create_new_targeting()
	var/datum/spell_targeting/click/C = new
	C.range = 7
	C.allowed_type = /mob/living/carbon/human
	return C

/obj/effect/proc_holder/spell/vampire/vampiric_deprival/cast(list/targets, mob/user)
	var/mob/living/carbon/human/target = targets[1]
	var/mob/living/carbon/human/human_user = user
	target.Beam(user, "sendbeam", time = 2 SECONDS)
	target.adjust_species_armour(-10, 20 SECONDS)
	human_user.adjust_species_armour(10, 20 SECONDS)

/obj/effect/proc_holder/spell/vampire/charge
	name = "Charge (30)"
	desc = "You charge at wherever you click on screen, dealing large amounts of damage, stunning and destroying walls and other objects."
	gain_desc = "You can now charge at a target on screen, dealing massive damage and destroying structures."
	required_blood = 30
	base_cooldown = 30 SECONDS
	action_icon_state = "vampire_charge"

/obj/effect/proc_holder/spell/vampire/charge/create_new_targeting()
	return new /datum/spell_targeting/clicked_atom

/obj/effect/proc_holder/spell/vampire/charge/can_cast(mob/user, charge_check, show_message)
	var/mob/living/L = user
	if(IS_HORIZONTAL(L))
		return FALSE
	return ..()

/obj/effect/proc_holder/spell/vampire/charge/cast(list/targets, mob/user)
	var/target = targets[1]
	if(isliving(user))
		var/mob/living/L = user
		L.apply_status_effect(STATUS_EFFECT_CHARGING)
		L.throw_at(target, targeting.range, 1, L, FALSE, callback = CALLBACK(L, /mob/living/.proc/remove_status_effect, STATUS_EFFECT_CHARGING))
