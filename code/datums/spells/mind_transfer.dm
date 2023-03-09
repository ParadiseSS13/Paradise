/obj/effect/proc_holder/spell/mind_transfer
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
	var/list/protected_roles = list("Wizard","Changeling","Cultist") //which roles are immune to the spell
	var/paralysis_amount_caster = 40 SECONDS //how much the caster is paralysed for after the spell
	var/paralysis_amount_victim = 40 SECONDS //how much the victim is paralysed for after the spell
	action_icon_state = "mindswap"

/obj/effect/proc_holder/spell/mind_transfer/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.allowed_type = /mob/living
	T.range = 1
	T.click_radius = 0
	return T

/obj/effect/proc_holder/spell/mind_transfer/valid_target(mob/living/target, mob/user)
	return target.stat != DEAD && target.key && target.mind

/*
Urist: I don't feel like figuring out how you store object spells so I'm leaving this for you to do.
Make sure spells that are removed from spell_list are actually removed and deleted when mind transfering.
Also, you never added distance checking after target is selected. I've went ahead and did that.
*/
/obj/effect/proc_holder/spell/mind_transfer/cast(list/targets, mob/living/user = usr)
	var/mob/living/target = targets[1]
	if(target.mind.special_role in protected_roles)
		return // base mindswap doesn't want cultists to suffer
	swap_bodies(target, user)
	target.Paralyse(paralysis_amount_caster)
	user.Paralyse(paralysis_amount_victim)

/obj/effect/proc_holder/spell/proc/swap_bodies(mob/living/target, mob/user)
	if(user.suiciding)
		to_chat(user, "<span class='warning'>You're killing yourself! You can't concentrate enough to do this!</span>")
		return

	if(issilicon(target))
		to_chat(user, "You feel this enslaved being is just as dead as its cold, hard exoskeleton.")
		return

	var/mob/living/victim = target//The target of the spell whos body will be transferred to.
	var/mob/living/caster = user//The wizard/whomever doing the body transferring.

	//MIND TRANSFER BEGIN
	if(length(caster.mind.special_verbs))//If the caster had any special verbs, remove them from the mob verb list.
		for(var/V in caster.mind.special_verbs)//Since the caster is using an object spell system, this is mostly moot.
			caster.verbs -= V//But a safety nontheless.

	if(length(victim.mind.special_verbs))//Now remove all of the victim's verbs.
		for(var/V in victim.mind.special_verbs)
			victim.verbs -= V

	var/mob/dead/observer/ghost = victim.ghostize(0)
	caster.mind.transfer_to(victim)

	if(length(victim.mind.special_verbs))//To add all the special verbs for the original caster.
		for(var/V in caster.mind.special_verbs)//Not too important but could come into play.
			caster.verbs += V

	ghost.mind.transfer_to(caster)
	if(ghost.key)
		GLOB.non_respawnable_keys -= ghost.ckey //ghostizing with an argument of 0 will make them unable to respawn forever, which is bad
		caster.key = ghost.key	//have to transfer the key since the mind was not active
	qdel(ghost)

	if(length(caster.mind.special_verbs))//If they had any special verbs, we add them here.
		for(var/V in caster.mind.special_verbs)
			caster.verbs += V

/obj/effect/proc_holder/spell/aoe/mass_mindswap //Basically Mass Ranged Mindswap
	name = "Mass mindswap"
	desc = "Shuffles the minds of everyone in your general vicinity."
	school = "transmutation"
	base_cooldown = 5 MINUTES
	clothes_req = FALSE
	invocation = "CRYO`ENTH VOUTH"
	invocation_type = "whisper"
	cooldown_min = 2 MINUTES
	action_icon_state = "mindswap"
	aoe_range = 30 // normally 2 screens
	smoke_type = SMOKE_HARMLESS
	smoke_amt = 1

/obj/effect/proc_holder/spell/aoe/mass_mindswap/create_new_targeting()
	var/datum/spell_targeting/aoe/targeting = new()
	targeting.range = aoe_range
	targeting.allowed_type = /mob/living
	return targeting

/obj/effect/proc_holder/spell/aoe/mass_mindswap/cast(list/targets, mob/user)
	var/list/mobs_to_swap = list()

	for(var/mob/living/mind_we_will_transfer as anything in targets)
		if(mind_we_will_transfer.stat != CONSCIOUS || !mind_we_will_transfer.mind || user == mind_we_will_transfer)
			continue //spare the casters and the poor SSD lads
		mobs_to_swap += mind_we_will_transfer

	if(!length(mobs_to_swap))
		return

	mobs_to_swap = shuffle(mobs_to_swap)

	while(length(mobs_to_swap) >= 2) // don't want someone transfering their mind into themselves
		var/mob/living/swap_to = pick_n_take(mobs_to_swap)
		var/mob/living/swap_from = pick_n_take(mobs_to_swap)

		swap_bodies(swap_to, swap_from)
