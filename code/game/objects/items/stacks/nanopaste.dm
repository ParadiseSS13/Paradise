/obj/item/stack/nanopaste
	name = "nanopaste"
	singular_name = "nanite swarm"
	desc = "A tube of paste containing swarms of repair nanites. Very effective in repairing robotic machinery."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "tube"
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "materials=2;engineering=3"
	amount = 6
	max_amount = 6
	toolspeed = 1

/obj/item/stack/nanopaste/attack(mob/living/M as mob, mob/user as mob)
	if(!istype(M) || !istype(user))
		return 0
	if(isrobot(M))	//Repairing cyborgs
		var/mob/living/silicon/robot/R = M
		if(R.getBruteLoss() || R.getFireLoss())
			R.heal_overall_damage(15, 15)
			use(1)
			user.visible_message("<span class='notice'>\The [user] applied some [src] at [R]'s damaged areas.</span>",\
				"<span class='notice'>You apply some [src] at [R]'s damaged areas.</span>")
		else
			to_chat(user, "<span class='notice'>All [R]'s systems are nominal.</span>")

	if(ishuman(M)) //Repairing robotic limbs and IPCs
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/S = H.get_organ(user.zone_selected)

		if(S && S.is_robotic())
			if(S.get_damage())
				use(1)
				var/remheal = 15
				var/nremheal = 0
				S.heal_damage(robo_repair = 1) //should in, theory, heal the robotic organs in just the targeted area with it being S instead of E
				var/childlist
				if(!isnull(S.children))
					childlist = S.children.Copy()
				var/parenthealed = FALSE
				while(remheal > 0)
					var/obj/item/organ/external/E
					if(S.get_damage())
						E = S
					else if(LAZYLEN(childlist))
						E = pick_n_take(childlist)
						if(!E.get_damage() || !E.is_robotic())
							continue
					else if(S.parent && !parenthealed)
						E = S.parent
						parenthealed = TRUE
						if(!E.get_damage() || !E.is_robotic())
							break
					else
						break
					nremheal = max(remheal - E.get_damage(), 0)
					E.heal_damage(remheal, 0, 0, 1) //Healing Brute
					E.heal_damage(0, remheal, 0, 1) //Healing Burn
					remheal = nremheal
					user.visible_message("<span class='notice'>\The [user] applies some nanite paste at \the [M]'s [E.name] with \the [src].</span>")
				if(H.bleed_rate && ismachineperson(H))
					H.bleed_rate = 0
			else
				to_chat(user, "<span class='notice'>Nothing to fix here.</span>")
		else
			to_chat(user, "<span class='notice'>[src] won't work on that.</span>")

/obj/item/stack/nanopaste/cyborg
	energy_type = /datum/robot_energy_storage/medical/nanopaste
	is_cyborg = TRUE

/obj/item/stack/nanopaste/cyborg/attack(mob/living/M, mob/user)
	if(get_amount() <= 0)
		to_chat(user, "<span class='warning'>You don't have enough energy to dispense more [name]!</span>")
	else
		return ..()

/obj/item/stack/nanopaste/cyborg/syndicate
	energy_type = /datum/robot_energy_storage/medical/nanopaste/syndicate
