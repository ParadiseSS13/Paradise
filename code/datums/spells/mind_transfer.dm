/obj/effect/proc_holder/spell/targeted/mind_transfer
	name = "Mind Transfer"
	desc = "This spell allows the user to switch bodies with a target."

	school = "transmutation"
	charge_max = 600
	clothes_req = 0
	invocation = "GIN'YU CAPAN"
	invocation_type = "whisper"
	range = 1
	cooldown_min = 200 //100 deciseconds reduction per rank
	var/list/protected_roles = list("Wizard","Changeling","Cultist") //which roles are immune to the spell
	var/paralysis_amount_caster = 20 //how much the caster is paralysed for after the spell
	var/paralysis_amount_victim = 20 //how much the victim is paralysed for after the spell
	action_icon_state = "mindswap"

/*
Urist: I don't feel like figuring out how you store object spells so I'm leaving this for you to do.
Make sure spells that are removed from spell_list are actually removed and deleted when mind transfering.
Also, you never added distance checking after target is selected. I've went ahead and did that.
*/
/obj/effect/proc_holder/spell/targeted/mind_transfer/cast(list/targets, mob/user = usr, distanceoverride)

	var/mob/living/target = targets[range]

	if(!(target in oview(range)) && !distanceoverride)//If they are not in overview after selection. Do note that !() is necessary for in to work because ! takes precedence over it.
		to_chat(user, "They are too far away!")
		return

	if(target.stat == DEAD)
		to_chat(user, "You don't particularly want to be dead.")
		return

	if(!target.key || !target.mind)
		to_chat(user, "[target.p_they(TRUE)] appear[target.p_s()] to be catatonic. Not even magic can affect [target.p_their()] vacant mind.")
		return

	if(user.suiciding)
		to_chat(user, "<span class='warning'>You're killing yourself! You can't concentrate enough to do this!</span>")
		return

	if(target.mind.special_role in protected_roles)
		to_chat(user, "Their mind is resisting your spell.")
		return

	if(istype(target, /mob/living/silicon))
		to_chat(user, "You feel this enslaved being is just as dead as its cold, hard exoskeleton.")
		return

	var/mob/living/victim = target//The target of the spell whos body will be transferred to.
	var/mob/caster = user//The wizard/whomever doing the body transferring.

	//MIND TRANSFER BEGIN
	if(caster.mind.special_verbs.len)//If the caster had any special verbs, remove them from the mob verb list.
		for(var/V in caster.mind.special_verbs)//Since the caster is using an object spell system, this is mostly moot.
			caster.verbs -= V//But a safety nontheless.

	if(victim.mind.special_verbs.len)//Now remove all of the victim's verbs.
		for(var/V in victim.mind.special_verbs)
			victim.verbs -= V

	var/mob/dead/observer/ghost = victim.ghostize(0)
	caster.mind.transfer_to(victim)

	if(victim.mind.special_verbs.len)//To add all the special verbs for the original caster.
		for(var/V in caster.mind.special_verbs)//Not too important but could come into play.
			caster.verbs += V

	ghost.mind.transfer_to(caster)
	if(ghost.key)
		GLOB.non_respawnable_keys -= ghost.ckey //ghostizing with an argument of 0 will make them unable to respawn forever, which is bad
		caster.key = ghost.key	//have to transfer the key since the mind was not active
	qdel(ghost)

	if(caster.mind.special_verbs.len)//If they had any special verbs, we add them here.
		for(var/V in caster.mind.special_verbs)
			caster.verbs += V
	//MIND TRANSFER END

	//Here we paralyze both mobs and knock them out for a time.
	caster.Paralyse(paralysis_amount_caster)
	victim.Paralyse(paralysis_amount_victim)
