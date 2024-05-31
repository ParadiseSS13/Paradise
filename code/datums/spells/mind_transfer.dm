/datum/spell/mind_transfer
	name = "Mind Transfer"
	desc = "This spell allows the user to switch bodies with a target."

	school = "transmutation"
	base_cooldown = 600
	clothes_req = FALSE
	invocation = "GIN'YU CAPAN"
	invocation_type = "whisper"
	selection_activated_message = "<span class='notice'>You prepare to transfer your mind. Click on a target to cast the spell.</span>"
	selection_deactivated_message = "<span class='notice'>You decide that your current form is good enough.</span>"
	cooldown_min = 200 //100 deciseconds reduction per rank
	var/list/protected_roles = list(SPECIAL_ROLE_WIZARD, SPECIAL_ROLE_CHANGELING, SPECIAL_ROLE_CULTIST) //which roles are immune to the spell
	var/paralysis_amount_caster = 40 SECONDS //how much the caster is paralysed for after the spell
	var/paralysis_amount_victim = 40 SECONDS //how much the victim is paralysed for after the spell
	action_icon_state = "mindswap"

/datum/spell/mind_transfer/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.allowed_type = /mob/living
	T.range = 1
	T.click_radius = 0
	return T

/datum/spell/mind_transfer/valid_target(mob/living/target, mob/user)
	return target.stat != DEAD && target.key && target.mind

/*
Urist: I don't feel like figuring out how you store object spells so I'm leaving this for you to do.
Make sure spells that are removed from spell_list are actually removed and deleted when mind transfering.
Also, you never added distance checking after target is selected. I've went ahead and did that.
*/
/datum/spell/mind_transfer/cast(list/targets, mob/user = usr)

	var/mob/living/target = targets[1]

	if(user.suiciding)
		to_chat(user, "<span class='warning'>You're killing yourself! You can't concentrate enough to do this!</span>")
		return

	if(target.mind.special_role in protected_roles)
		to_chat(user, "Their mind is resisting your spell.")
		return

	if(issilicon(target))
		to_chat(user, "You feel this enslaved being is just as dead as its cold, hard exoskeleton.")
		return

	var/mob/living/victim = target//The target of the spell whos body will be transferred to.
	var/mob/living/caster = user//The wizard/whomever doing the body transferring.

	//MIND TRANSFER BEGIN
	if(length(caster.mind.special_verbs))//If the caster had any special verbs, remove them from the mob verb list.
		for(var/V in caster.mind.special_verbs)//Since the caster is using an object spell system, this is mostly moot.
			remove_verb(caster, V) //But a safety nontheless.

	if(length(victim.mind.special_verbs))//Now remove all of the victim's verbs.
		for(var/V in victim.mind.special_verbs)
			remove_verb(victim, V)

	var/mob/dead/observer/ghost = victim.ghostize(0)
	caster.mind.transfer_to(victim)

	if(length(victim.mind.special_verbs))//To add all the special verbs for the original caster.
		for(var/V in caster.mind.special_verbs)//Not too important but could come into play.
			add_verb(caster, V)

	ghost.mind.transfer_to(caster)
	if(ghost.key)
		GLOB.non_respawnable_keys -= ghost.ckey
		caster.key = ghost.key	//have to transfer the key since the mind was not active
	qdel(ghost)

	if(length(caster.mind.special_verbs))//If they had any special verbs, we add them here.
		for(var/V in caster.mind.special_verbs)
			add_verb(caster, V)
	//MIND TRANSFER END

	//Here we paralyze both mobs and knock them out for a time.
	caster.Paralyse(paralysis_amount_caster)
	victim.Paralyse(paralysis_amount_victim)
