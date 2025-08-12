/datum/spell/vampire/self/cloak
	name = "Cloak of Darkness"
	desc = "Toggles whether you are currently cloaking yourself in darkness. When in darkness and toggled on, you move at increased speeds."
	gain_desc = "You have gained the Cloak of Darkness ability, which when toggled makes you nearly invisible and highly agile in the shroud of darkness."
	action_icon_state = "vampire_cloak"
	base_cooldown = 2 SECONDS

/datum/spell/vampire/self/cloak/proc/update_spell_name(mob/living/user)
	if(!ishuman(user) || !user.mind)
		return
	var/datum/antagonist/vampire/V = user.mind.has_antag_datum(/datum/antagonist/vampire)
	if(!V)
		return

	action.name = "[initial(name)] ([V.iscloaking ? "Deactivate" : "Activate"])"
	SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_NAME)
	build_all_button_icons()

/datum/spell/vampire/self/cloak/cast(list/targets, mob/user = usr)
	var/datum/antagonist/vampire/V = user.mind.has_antag_datum(/datum/antagonist/vampire)
	V.iscloaking = !V.iscloaking
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(V.iscloaking)
			H.physiology.burn_mod *= 1.1
			user.RegisterSignal(user, COMSIG_LIVING_IGNITED, TYPE_PROC_REF(/mob/living, update_vampire_cloak))
		else
			user.UnregisterSignal(user, COMSIG_LIVING_IGNITED)
			H.physiology.burn_mod /= 1.1
	update_spell_name(user)
	to_chat(user, "<span class='notice'>You will now be [V.iscloaking ? "hidden" : "seen"] in darkness.</span>")

/mob/living/proc/update_vampire_cloak()
	SIGNAL_HANDLER
	var/datum/antagonist/vampire/V = mind.has_antag_datum(/datum/antagonist/vampire)
	V.handle_vampire_cloak()

/datum/spell/vampire/shadow_snare
	name = "Shadow Snare (20)"
	desc = "You summon a trap on the ground. When crossed it will blind the target, extinguish any lights they may have, and ensnare them."
	gain_desc = "You have gained the ability to summon a trap that will blind, ensnare, and turn off the lights of anyone who crosses it."
	base_cooldown = 20 SECONDS
	required_blood = 20
	action_icon_state = "shadow_snare"

/datum/spell/vampire/shadow_snare/create_new_targeting()
	var/datum/spell_targeting/click/T = new
	T.allowed_type = /turf/simulated
	T.click_radius = -1
	return T

/datum/spell/vampire/shadow_snare/cast(list/targets, mob/user)
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

/obj/item/restraints/legcuffs/beartrap/shadow_snare/on_atom_entered(datum/source, atom/movable/entered)
	if(!iscarbon(entered) || !armed)
		return
	var/mob/living/carbon/C = entered
	if(!C.affects_vampire()) // no parameter here so holy always protects
		return
	C.extinguish_light()
	C.EyeBlind(20 SECONDS)
	STOP_PROCESSING(SSobj, src) // won't wither away once you are trapped

	. = ..()

	if(!iscarbon(loc)) // if it fails to latch onto someone for whatever reason, delete itself, we don't want unarmed ones lying around.
		qdel(src)

/obj/item/restraints/legcuffs/beartrap/shadow_snare/attack_hand(mob/user)
	Crossed(user)

/obj/item/restraints/legcuffs/beartrap/shadow_snare/attack_tk(mob/user)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		to_chat(user, "<span class='userdanger'>The snare sends a psychic backlash!</span>")
		C.EyeBlind(20 SECONDS)

/obj/item/restraints/legcuffs/beartrap/shadow_snare/attackby__legacy__attackchain(obj/item/I, mob/user)
	var/obj/item/flash/flash = I
	if(!istype(flash) || !flash.try_use_flash(user))
		return ..()
	user.visible_message("<span class='danger'>[user] points [I] at [src]!</span>",
	"<span class='danger'>You point [I] at [src]!</span>")
	visible_message("<span class='notice'>[src] withers away.</span>")
	qdel(src)

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

/datum/spell/vampire/soul_anchor
	name = "Soul Anchor (30)"
	desc = "You summon a dimensional anchor after a delay. Casting again will teleport you back to the anchor. You will fake a recall after 2 minutes."
	gain_desc = "You have gained the ability to save a point in space and teleport back to it at will. Unless you willingly teleport back to that point within 2 minutes, you will fake a recall."
	required_blood = 30
	centcom_cancast = FALSE
	base_cooldown = 3 MINUTES
	action_icon_state = "shadow_anchor"
	should_recharge_after_cast = FALSE
	deduct_blood_on_cast = FALSE
	var/obj/structure/shadow_anchor/anchor
	/// Are we making an anchor?
	var/making_anchor = FALSE
	/// Holds a reference to the timer until the caster fake recalls
	var/timer

/datum/spell/vampire/soul_anchor/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/vampire/soul_anchor/cast(list/targets, mob/user)
	if(making_anchor) // second cast, but we are impatient
		to_chat(user, "<span class='notice'>Your anchor isn't ready yet!</span>")
		return

	if(!making_anchor && !anchor) // first cast, setup the anchor
		var/turf/anchor_turf = get_turf(user)
		making_anchor = TRUE
		if(do_mob(user, user, 5 SECONDS, only_use_extra_checks = TRUE, hidden = TRUE)) // no checks, cant fail
			make_anchor(user, anchor_turf)
			making_anchor = FALSE
			return

	if(anchor) // second cast, teleport us back
		recall(user)


/datum/spell/vampire/soul_anchor/proc/make_anchor(mob/user, turf/anchor_turf)
	anchor = new(anchor_turf)
	timer = addtimer(CALLBACK(src, PROC_REF(recall), user, TRUE), 2 MINUTES, TIMER_STOPPABLE)

/datum/spell/vampire/soul_anchor/proc/recall(mob/user, fake = FALSE)
	cooldown_handler.start_recharge()
	if(timer)
		deltimer(timer)
		timer = null
	var/turf/start_turf = get_turf(user)
	var/turf/end_turf = get_turf(anchor)
	QDEL_NULL(anchor)
	if(end_turf.z != start_turf.z)
		return
	if(!is_teleport_allowed(end_turf.z))
		return

	if(fake)
		var/mob/living/simple_animal/hostile/illusion/escape/E = new(end_turf)
		E.Copy_Parent(user, 10 SECONDS)
		for(var/mob/living/L in view(7, E)) //We want it to start running
			E.GiveTarget(L)
			break
		user.make_invisible()
		addtimer(CALLBACK(user, TYPE_PROC_REF(/mob/living, reset_visibility)), 4 SECONDS)
	else
		if(SEND_SIGNAL(user, COMSIG_MOVABLE_TELEPORTING, end_turf) & COMPONENT_BLOCK_TELEPORT) //You can fake it out, but no teleporting
			return FALSE
		user.forceMove(end_turf)

	if(end_turf.z == start_turf.z)
		shadow_to_animation(start_turf, end_turf, user)

	var/datum/spell_handler/vampire/V = custom_handler
	var/datum/antagonist/vampire/vampire = user.mind.has_antag_datum(/datum/antagonist/vampire)
	var/blood_cost = V.calculate_blood_cost(vampire)
	vampire.subtract_usable_blood(blood_cost)// Vampires get a coupon if they have less than the normal blood cost

/proc/shadow_to_animation(turf/start_turf, turf/end_turf, mob/user)
	var/x_difference = end_turf.x - start_turf.x
	var/y_difference = end_turf.y - start_turf.y
	var/distance = sqrt(x_difference ** 2 + y_difference ** 2) // pythag baby

	var/obj/effect/immortality_talisman/effect = new(start_turf)
	effect.dir = user.dir
	effect.can_destroy = TRUE

	var/animation_time = distance
	animate(effect, time = animation_time, alpha = 0, pixel_x = x_difference * 32, pixel_y = y_difference * 32) //each turf is 32 pixels long
	QDEL_IN(effect, animation_time)

// an indicator that shows where the vampire will land
/obj/structure/shadow_anchor
	name = "shadow anchor"
	desc = "Looking at this thing makes you feel uneasy..."
	icon = 'icons/obj/cult.dmi'
	icon_state = "pylon"
	alpha = 120
	color = "#545454"
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE

/datum/spell/vampire/dark_passage
	name = "Dark Passage (30)"
	desc = "You teleport to a targeted turf."
	gain_desc = "You have gained the ability to blink a short distance towards a targeted turf."
	base_cooldown = 40 SECONDS
	required_blood = 30
	centcom_cancast = FALSE
	action_icon_state = "dark_passage"

/datum/spell/vampire/dark_passage/create_new_targeting()
	var/datum/spell_targeting/click/T = new
	T.click_radius = 0
	T.allowed_type = /turf/simulated
	return T

/datum/spell/vampire/dark_passage/cast(list/targets, mob/user)
	var/turf/target = get_turf(targets[1])
	if(SEND_SIGNAL(user, COMSIG_MOVABLE_TELEPORTING, target) & COMPONENT_BLOCK_TELEPORT)
		return FALSE

	new /obj/effect/temp_visual/vamp_mist_out(get_turf(user))

	user.forceMove(target)

/obj/effect/temp_visual/vamp_mist_out
	duration = 2 SECONDS
	icon = 'icons/mob/mob.dmi'
	icon_state = "mist"

/datum/spell/vampire/vamp_extinguish
	name = "Extinguish"
	desc = "You extinguish any light source in an area around you."
	gain_desc = "You have gained the ability to extinguish nearby light sources."
	base_cooldown = 20 SECONDS
	action_icon_state = "vampire_extinguish"
	create_attack_logs = FALSE
	create_custom_logs = TRUE

/datum/spell/vampire/vamp_extinguish/create_new_targeting()
	var/datum/spell_targeting/aoe/turf/T = new
	return T

/datum/spell/vampire/vamp_extinguish/cast(list/targets, mob/user = usr)
	for(var/turf/T in targets)
		T.extinguish_light()
		for(var/atom/A in T.contents)
			A.extinguish_light()

/datum/spell/vampire/shadow_boxing
	name = "Shadow Boxing (50)"
	desc = "Target someone to have your shadow beat them up. You must stay within 2 tiles for this to work."
	gain_desc = "You have gained the ability to make your shadow fight for you."
	base_cooldown = 30 SECONDS
	action_icon_state = "shadow_boxing"
	required_blood = 50
	var/target_UID

/datum/spell/vampire/shadow_boxing/create_new_targeting()
	var/datum/spell_targeting/click/C = new
	C.allowed_type = /mob/living
	C.range = 2
	C.try_auto_target = FALSE
	return C

/datum/spell/vampire/shadow_boxing/cast(list/targets, mob/user)
	var/mob/living/target = targets[1]
	target.apply_status_effect(STATUS_EFFECT_SHADOW_BOXING, user)

/datum/spell/vampire/self/eternal_darkness
	name = "Eternal Darkness"
	desc = "When toggled, you shroud the area around you in darkness and slowly lower the body temperature of people nearby. Energy projectiles will dim in its radius."
	gain_desc = "You have gained the ability to shroud the area around you in darkness. Only the strongest of lights can pierce your unholy powers."
	action_icon_state = "eternal_darkness"
	required_blood = 5
	var/shroud_power = -6

/datum/spell/vampire/self/eternal_darkness/cast(list/targets, mob/user)
	var/datum/antagonist/vampire/V = user.mind.has_antag_datum(/datum/antagonist/vampire)
	var/mob/target = targets[1]
	if(!V.get_ability(/datum/vampire_passive/eternal_darkness))
		V.force_add_ability(/datum/vampire_passive/eternal_darkness)
		target.set_light(8, shroud_power, "#ddd6cf")
	else
		for(var/datum/vampire_passive/eternal_darkness/E in V.powers)
			V.remove_ability(E)

/datum/vampire_passive/eternal_darkness
	gain_desc = "You surround yourself in a unnatural darkness, freezing those around you and dimming energy projectiles."

/datum/vampire_passive/eternal_darkness/New()
	..()
	START_PROCESSING(SSfastprocess, src)

/datum/vampire_passive/eternal_darkness/Destroy(force, ...)
	owner.remove_light()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/datum/vampire_passive/eternal_darkness/process()
	var/datum/antagonist/vampire/V = owner.mind.has_antag_datum(/datum/antagonist/vampire)

	for(var/mob/living/L in view(8, owner))
		if(L.affects_vampire(owner))
			L.adjust_bodytemperature(-3 * TEMPERATURE_DAMAGE_COEFFICIENT) //The dark is cold and unforgiving. Equivelnt to -60 with previous values.
	for(var/obj/item/projectile/P in view(8, owner))
		if(P.flag == ENERGY || P.flag == LASER)
			P.damage *= 0.7

	V.bloodusable = max(V.bloodusable - 0.25, 0) //2.5 per second, 5 per 2, same as before

	if(!V.bloodusable || owner.stat == DEAD)
		V.remove_ability(src)

/datum/vampire_passive/vision/xray
	gain_desc = "You can now see through walls, incase you hadn't noticed."
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	see_in_dark = 8
	vision_flags = SEE_TURFS|SEE_MOBS|SEE_OBJS
