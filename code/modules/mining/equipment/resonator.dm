/**********************Resonator**********************/
/obj/item/resonator
	name = "resonator"
	icon = 'icons/obj/mining_tool.dmi'
	icon_state = "resonator"
	origin_tech = "magnets=3;engineering=3"
	desc = "A handheld device that creates small fields of energy that resonate until they detonate, crushing rock. It can also be activated without a target to create a field at the user's location, to act as a delayed time trap. It's more effective in a vaccuum."
	force = 15
	throwforce = 10

	/// the mode of the resonator; has three modes: auto (1), manual (2), and matrix (3)
	var/mode = RESONATOR_MODE_AUTO
	/// How efficient it is in manual mode. Yes, we lower the damage cuz it's gonna be used for mobhunt
	var/quick_burst_mod = 0.8
	/// the number of fields the resonator is allowed to have at once
	var/fieldlimit = 4
	/// the list of currently active fields from this resonator
	var/list/fields = list()
	/// the number that is added to the failure_prob, which is the probability of whether it will spread or not
	var/adding_failure = 50

/obj/item/resonator/attack_self__legacy__attackchain(mob/user)
	if(mode == RESONATOR_MODE_AUTO)
		to_chat(user, "<span class='notice'>You set the [name]'s fields to detonate only after you hit it with [src].</span>")
		mode = RESONATOR_MODE_MANUAL
	else
		to_chat(user, "<span class='notice'>You set [src]'s fields to detonate after 2 seconds.</span>")
		mode = RESONATOR_MODE_AUTO

/obj/item/resonator/upgraded
	name = "upgraded resonator"
	desc = "An upgraded version of the resonator that can produce more fields at once, as well as having no damage penalty for bursting a resonance field early. It also allows you to set 'Resonance matrixes', that detonate after someone (or something) walks over it."
	icon_state = "resonator_u"
	origin_tech = "materials=4;powerstorage=3;engineering=3;magnets=3"
	fieldlimit = 6
	quick_burst_mod = 1

/obj/item/resonator/upgraded/attack_self__legacy__attackchain(mob/user)
	if(mode == RESONATOR_MODE_AUTO)
		to_chat(user, "<span class='notice'>You set [src]'s fields to detonate only after being attacked by [src].</span>")
		mode = RESONATOR_MODE_MANUAL
	else if(mode == RESONATOR_MODE_MANUAL)
		to_chat(user, "<span class='notice'>You set [src]'s fields to work as matrix traps.</span>")
		mode = RESONATOR_MODE_MATRIX
	else
		to_chat(user, "<span class='notice'>You set [src]'s fields to detonate automatically after 2 seconds.</span>")
		mode = RESONATOR_MODE_AUTO

/obj/item/resonator/proc/create_resonance(target, mob/user)
	var/turf/target_turf = get_turf(target)
	var/obj/effect/temp_visual/resonance/resonance_field = locate(/obj/effect/temp_visual/resonance) in target_turf
	if(resonance_field)
		resonance_field.damage_multiplier = quick_burst_mod
		resonance_field.burst()
		return
	if(LAZYLEN(fields) < fieldlimit)
		new /obj/effect/temp_visual/resonance(target_turf, user, src, mode, adding_failure)
		user.changeNext_move(CLICK_CD_MELEE)

/obj/item/resonator/pre_attack(atom/target, mob/user, params)
	if(check_allowed_items(target, not_inside = TRUE))
		create_resonance(target, user)
	return ..()

//resonance field, crushes rock, damages mobs
/obj/effect/temp_visual/resonance
	name = "resonance field"
	desc = "A resonating field that significantly damages anything inside of it when the field eventually ruptures. More damaging in low pressure environments."
	icon_state = "shield1"
	layer = ABOVE_ALL_MOB_LAYER
	duration = 60 SECONDS
	/// the amount of damage living beings will take whilst inside the field during its burst
	var/resonance_damage = 20
	/// the modifier to resonance_damage; affected by the quick_burst_mod from the resonator
	var/damage_multiplier = 1
	/// the parent creator (user) of this field
	var/mob/creator
	/// the parent resonator of this field
	var/obj/item/resonator/parent_resonator
	/// whether the field is rupturing currently or not (to prevent recursion)
	var/rupturing = FALSE
	/// the probability that the field will not be able to spread
	var/failure_prob = 0
	/// the number that is added to the failure_prob. Will default to 50
	var/adding_failure

/obj/effect/temp_visual/resonance/Initialize(mapload, set_creator, set_resonator, mode, set_failure = 50)
	if(mode == RESONATOR_MODE_AUTO)
		duration = 2 SECONDS
	if(mode == RESONATOR_MODE_MATRIX)
		icon_state = "shield2"
		name = "resonance matrix"
		RegisterSignal(src, COMSIG_ATOM_ENTERED, PROC_REF(burst))
		var/static/list/loc_connections = list(
				COMSIG_ATOM_ENTERED = PROC_REF(burst),
		)
		AddElement(/datum/element/connect_loc, loc_connections)
	. = ..()
	creator = set_creator
	parent_resonator = set_resonator
	if(parent_resonator)
		parent_resonator.fields += src
	adding_failure = set_failure
	playsound(src, 'sound/weapons/resonator_blast.ogg', 50, TRUE)
	if(mode == RESONATOR_MODE_AUTO)
		transform = matrix() * 0.75
		animate(src, transform = matrix() * 1.5, time = duration)
	deltimer(timerid)
	timerid = addtimer(CALLBACK(src, PROC_REF(burst)), duration, TIMER_STOPPABLE)

/obj/effect/temp_visual/resonance/Destroy()
	if(parent_resonator)
		parent_resonator.fields -= src
		parent_resonator = null
	creator = null
	. = ..()

/obj/effect/temp_visual/resonance/proc/check_pressure(turf/proj_turf)
	if(!proj_turf)
		proj_turf = get_turf(src)
	resonance_damage = initial(resonance_damage)
	if(lavaland_equipment_pressure_check(proj_turf))
		name = "strong [initial(name)]"
		resonance_damage *= 3
	else
		name = initial(name)
	resonance_damage *= damage_multiplier

/obj/effect/temp_visual/resonance/proc/burst()
	SIGNAL_HANDLER  // COMSIG_ATOM_ENTERED
	if(rupturing)
		return
	rupturing = TRUE
	var/turf/src_turf = get_turf(src)
	new /obj/effect/temp_visual/resonance_crush(src_turf)
	if(ismineralturf(src_turf))
		var/turf/simulated/mineral/mineral_turf = src_turf
		if(is_ancient_rock(mineral_turf))
			failure_prob = 100 // rock too strong for resonance field
			visible_message("<span class='notice'>This rock appears to be resistant to all mining tools except pickaxes!</span>")
		else
			mineral_turf.gets_drilled(creator)
	check_pressure(src_turf)
	playsound(src_turf, 'sound/weapons/resonator_blast.ogg', 50, TRUE)
	for(var/mob/living/attacked_living in src_turf)
		if(creator)
			log_attack(creator, attacked_living, "used a resonator field on", "resonator")
		to_chat(attacked_living, "<span class='danger'>[src] ruptured with you in it!</span>")
		attacked_living.apply_damage(resonance_damage, BRUTE)
	for(var/obj/effect/temp_visual/resonance/field in orange(1, src))
		if(field.rupturing)
			continue
		if(parent_resonator.mode == RESONATOR_MODE_AUTO || parent_resonator.mode == RESONATOR_MODE_MANUAL)
			field.burst()
	if(!prob(failure_prob) && parent_resonator)
		for(var/turf/simulated/mineral/mineral_spread in orange(1, src))
			if(locate(/obj/effect/temp_visual/resonance) in mineral_spread)
				continue
			var/obj/effect/temp_visual/resonance/new_field = new(mineral_spread, creator, parent_resonator, parent_resonator.mode)
			new_field.failure_prob = failure_prob + adding_failure
	qdel(src)

/obj/effect/temp_visual/resonance_crush
	icon_state = "shield1"
	layer = ABOVE_ALL_MOB_LAYER
	duration = 4

/obj/effect/temp_visual/resonance_crush/Initialize(mapload)
	. = ..()
	transform = matrix() * 1.5
	animate(src, transform = matrix() * 0.1, alpha = 50, time = 4)
