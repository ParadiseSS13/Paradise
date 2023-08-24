/**
 *  Guardian's mines. Can be attached to anything to do explosive stuff on a victim.
 */
#define MINE_LIFE_TIME 60 SECONDS

///Datum specialized for guardian(holoparasite)-bomber.
/datum/component/guardian_mine
	var/mob/living/simple_animal/hostile/guardian/bomb/bomber
	var/is_exploded = FALSE

/datum/component/guardian_mine/Initialize(mob/living/simple_animal/hostile/guardian/bomb/guardian)
	bomber = guardian
	if(!istype(bomber))
		return COMPONENT_INCOMPATIBLE
	addtimer(CALLBACK(src, PROC_REF(defuse)), MINE_LIFE_TIME)

/datum/component/guardian_mine/RegisterWithParent()
	RegisterSignal(parent, list(
		COMSIG_ATOM_ATTACK_HAND,
		COMSIG_ITEM_PICKUP,
		COMSIG_CLICK_ALT,
		COMSIG_ATOM_BUMPED,
		COMSIG_ATOM_START_PULL,
		COMSIG_ATOM_ATTACK,
		COMSIG_PARENT_ATTACKBY,
		COMSIG_MOVABLE_BUCKLE,
		COMSIG_MOVABLE_IMPACT
		),
		PROC_REF(explode))

	RegisterSignal(parent, list(COMSIG_PARENT_EXAMINE), PROC_REF(examine_mined))

/datum/component/guardian_mine/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ATOM_ATTACK_HAND,
		COMSIG_ITEM_PICKUP,
		COMSIG_CLICK_ALT,
		COMSIG_ATOM_BUMPED,
		COMSIG_ATOM_START_PULL,
		COMSIG_ATOM_ATTACK,
		COMSIG_PARENT_ATTACKBY,
		COMSIG_MOVABLE_BUCKLE,
		COMSIG_MOVABLE_IMPACT)
		)

	UnregisterSignal(parent, list(COMSIG_PARENT_EXAMINE))


/datum/component/guardian_mine/proc/defuse()
	if(is_exploded)
		return
	if(bomber)
		to_chat(bomber, "Провал! Ваша мина на [parent] не смогла никого поймать на сей раз.")
	UnregisterFromParent()

/datum/component/guardian_mine/proc/examine_mined(atom/parent_atom, mob/victim)
	if(get_dist(victim, parent_atom) <= 2)
		to_chat(victim, span_notice("[parent_atom] looks odd!"))

/datum/component/guardian_mine/proc/explode(atom/parent_atom, mob/living/victim)
	if(!istype(victim))
		return
	if(get_dist(get_turf(parent_atom), get_turf(victim)) > 1)
		return
	if(victim == bomber)
		return
	if(victim == bomber.summoner)
		return
	add_attack_logs(victim, parent_atom, "booby trap TRIGGERED (spawner: [bomber], ckey: [bomber.ckey])")
	to_chat(victim, span_danger("Это ловушка! [parent_atom] был заминирован!"))
	playsound(get_turf(parent_atom),'sound/effects/bomb_activate.ogg', 200, 1)
	playsound(get_turf(parent_atom),'sound/effects/explosion1.ogg', 200, 1)
	victim.ex_act(3)
	victim.Weaken(6 SECONDS)
	if(ishuman(victim))
		dead_legs(victim)
	victim.adjustBruteLoss(40)
	is_exploded = TRUE
	UnregisterFromParent()

/datum/component/guardian_mine/proc/dead_legs(mob/living/carbon/human/human)
	var/obj/item/organ/external/l = human.get_organ("l_leg")
	var/obj/item/organ/external/r = human.get_organ("r_leg")
	if(l && prob(50))
		l.droplimb(0, DROPLIMB_SHARP)
	if(r && prob(50))
		r.droplimb(0, DROPLIMB_SHARP)
