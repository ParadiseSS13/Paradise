/obj/item/stack/nanopaste
	name = "nanopaste"
	singular_name = "nanite swarm"
	desc = "A tube of paste containing swarms of repair nanites. Very effective in repairing robotic machinery."
	icon = 'icons/obj/nanopaste.dmi'
	icon_state = "tube"
	origin_tech = "materials=2;engineering=3"
	amount = 6
	max_amount = 6
	toolspeed = 1

/obj/item/stack/nanopaste/attack(mob/living/M as mob, mob/user as mob)
	if(!istype(M) || !istype(user))
		return 0
	if(istype(M,/mob/living/silicon/robot))	//Repairing cyborgs
		var/mob/living/silicon/robot/R = M
		if(R.getBruteLoss() || R.getFireLoss() )
			R.heal_overall_damage(15, 15)
			use(1)
			user.visible_message("<span class='notice'>\The [user] applied some [src] at [R]'s damaged areas.</span>",\
				"<span class='notice'>You apply some [src] at [R]'s damaged areas.</span>")
		else
			to_chat(user, "<span class='notice'>All [R]'s systems are nominal.</span>")

	if(istype(M,/mob/living/carbon/human))		//Repairing robolimbs
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/S = H.get_organ(user.zone_sel.selecting)

		if(S && S.is_robotic())
			if(S.get_damage())
				S.heal_damage(15, 15, robo_repair = 1)
				use(1)
				user.visible_message("<span class='notice'>\The [user] applies some nanite paste at[user != M ? " \the [M]'s" : " \the"][S.name] with \the [src].</span>",\
				"<span class='notice'>You apply some nanite paste at [user == M ? "your" : "[M]'s"] [S.name].</span>")
			else
				to_chat(user, "<span class='notice'>Nothing to fix here.</span>")
		else
			to_chat(user, "<span class='notice'>[src] won't work on that.</span>")

/obj/item/stack/nanopaste/proc/heal(mob/living/M, mob/user)
	var/mob/living/carbon/human/H = M
	var/obj/item/organ/external/affecting = H.get_organ(user.zone_sel.selecting)
	user.visible_message("<span class='green'>[user] [healverb]s the damage on [H]'s [affecting.name].</span>", \
						 "<span class='green'>You [healverb] the damage on [H]'s [affecting.name].</span>" )

	var/rembrute = max(0, heal_brute - affecting.brute_dam) // Maxed with 0 since heal_damage let you pass in a negative value
	var/remburn = max(0, heal_burn - affecting.burn_dam) // And deduct it from their health (aka deal damage)
	var/nrembrute = rembrute
	var/nremburn = remburn
	affecting.heal_damage(heal_brute, heal_burn)
	var/list/achildlist
	if(!isnull(affecting.children))
		achildlist = affecting.children.Copy()
	var/parenthealed = FALSE
	while(rembrute + remburn > 0) // Don't bother if there's not enough leftover heal
		var/obj/item/organ/external/E
		if(LAZYLEN(achildlist))
			E = pick_n_take(achildlist) // Pick a random children and then remove it from the list
		else if(affecting.parent && !parenthealed) // If there's a parent and no healing attempt was made on it
			E = affecting.parent
			parenthealed = TRUE
		else
			break // If the organ have no child left and no parent / parent healed, break
		if(E.status != ORGAN_ROBOT) // Ignores organic limb
			continue
		else if(!E.brute_dam && !E.burn_dam) // Ignore undamaged limb
			continue
		nrembrute = max(0, rembrute - E.brute_dam) // Deduct the healed damage from the remain
		nremburn = max(0, remburn - E.burn_dam)
		E.heal_damage(rembrute, remburn)
		rembrute = nrembrute
		remburn = nremburn
		user.visible_message("<span class='green'>[user] [healverb]s the damage on [H]'s [E.name] with the remaining paste.</span>", \
							 "<span class='green'>You [healverb] the damage on [H]'s [E.name] with the remaining paste.</span>" )