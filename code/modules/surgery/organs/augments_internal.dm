#define STUN_SET_AMOUNT	2

/obj/item/organ/internal/cyberimp
	name = "cybernetic implant"
	desc = "a state-of-the-art implant that improves a baseline's functionality"
	status = ORGAN_ROBOT
	var/implant_color = "#FFFFFF"
	var/implant_overlay
	tough = 1 //not easyly broken by combat damage
	sterile = 1 //not very germy

/obj/item/organ/internal/cyberimp/New(var/mob/M = null)
	if(iscarbon(M))
		src.insert(M)
	if(implant_overlay)
		var/image/overlay = new /image(icon, implant_overlay)
		overlay.color = implant_color
		overlays |= overlay
	return ..()



//[[[[BRAIN]]]]

/obj/item/organ/internal/cyberimp/brain
	name = "cybernetic brain implant"
	desc = "injectors of extra sub-routines for the brain"
	icon_state = "brain_implant"
	implant_overlay = "brain_implant_overlay"
	parent_organ = "head"

/obj/item/organ/internal/cyberimp/brain/emp_act(severity)
	if(!owner)
		return
	var/stun_amount = 5 + (severity-1 ? 0 : 5)
	owner.Stun(stun_amount)
	to_chat(owner, "<span class='warning'>Your body seizes up!</span>")
	return stun_amount


/obj/item/organ/internal/cyberimp/brain/anti_drop
	name = "Anti-drop implant"
	desc = "This cybernetic brain implant will allow you to force your hand muscles to contract, preventing item dropping. Twitch ear to toggle."
	var/active = 0
	var/l_hand_ignore = 0
	var/r_hand_ignore = 0
	var/obj/item/l_hand_obj = null
	var/obj/item/r_hand_obj = null
	implant_color = "#DE7E00"
	slot = "brain_antidrop"
	origin_tech = "materials=5;programming=4;biotech=4"
	actions_types = list(/datum/action/item_action/organ_action/toggle)

/obj/item/organ/internal/cyberimp/brain/anti_drop/ui_action_click()
	active = !active
	if(active)
		l_hand_obj = owner.l_hand
		r_hand_obj = owner.r_hand
		if(l_hand_obj)
			if(owner.l_hand.flags & NODROP)
				l_hand_ignore = 1
			else
				owner.l_hand.flags |= NODROP
				l_hand_ignore = 0

		if(r_hand_obj)
			if(owner.r_hand.flags & NODROP)
				r_hand_ignore = 1
			else
				owner.r_hand.flags |= NODROP
				r_hand_ignore = 0

		if(!l_hand_obj && !r_hand_obj)
			to_chat(owner, "<span class='notice'>You are not holding any items, your hands relax...</span>")
			active = 0
		else
			var/msg = 0
			msg += !l_hand_ignore && l_hand_obj ? 1 : 0
			msg += !r_hand_ignore && r_hand_obj ? 2 : 0
			switch(msg)
				if(1)
					to_chat(owner, "<span class='notice'>Your left hand's grip tightens.</span>")
				if(2)
					to_chat(owner, "<span class='notice'>Your right hand's grip tightens.</span>")
				if(3)
					to_chat(owner, "<span class='notice'>Both of your hand's grips tighten.</span>")
	else
		release_items()
		to_chat(owner, "<span class='notice'>Your hands relax...</span>")
		l_hand_obj = null
		r_hand_obj = null

/obj/item/organ/internal/cyberimp/brain/anti_drop/emp_act(severity)
	if(!owner)
		return
	var/range = severity ? 10 : 5
	var/atom/A
	var/obj/item/L_item = owner.l_hand
	var/obj/item/R_item = owner.r_hand

	release_items()
	..()
	if(L_item)
		A = pick(oview(range))
		L_item.throw_at(A, range, 2)
		to_chat(owner, "<span class='notice'>Your left arm spasms and throws the [L_item.name]!</span>")
	if(R_item)
		A = pick(oview(range))
		R_item.throw_at(A, range, 2)
		to_chat(owner, "<span class='notice'>Your right arm spasms and throws the [R_item.name]!</span>")

/obj/item/organ/internal/cyberimp/brain/anti_drop/proc/release_items()
	if(!l_hand_ignore && l_hand_obj in owner.contents)
		l_hand_obj.flags ^= NODROP
	if(!r_hand_ignore && r_hand_obj in owner.contents)
		r_hand_obj.flags ^= NODROP

/obj/item/organ/internal/cyberimp/brain/anti_drop/remove(var/mob/living/carbon/M, special = 0)
	. = ..()
	if(active)
		ui_action_click()


/obj/item/organ/internal/cyberimp/brain/anti_stun
	name = "CNS Rebooter implant"
	desc = "This implant will automatically give you back control over your central nervous system, reducing downtime when stunned."
	implant_color = "#FFFF00"
	slot = "brain_antistun"
	origin_tech = "materials=6;programming=4;biotech=5"

/obj/item/organ/internal/cyberimp/brain/anti_stun/on_life()
	..()
	if(crit_fail)
		return
	if(owner.stunned > STUN_SET_AMOUNT)
		owner.stunned = STUN_SET_AMOUNT
	if(owner.weakened > STUN_SET_AMOUNT)
		owner.weakened = STUN_SET_AMOUNT

/obj/item/organ/internal/cyberimp/brain/anti_stun/emp_act(severity)
	if(crit_fail)
		return
	crit_fail = 1
	spawn(90 / severity)
		crit_fail = 0

/obj/item/organ/internal/cyberimp/brain/clown_voice
	name = "Comical implant"
	desc = "<span class='sans'>Uh oh.</span>"
	implant_color = "#DEDE00"
	slot = "brain_clownvoice"
	origin_tech = "materials=2;biotech=2"

//[[[[CHEST]]]]
/obj/item/organ/internal/cyberimp/chest
	name = "cybernetic torso implant"
	desc = "implants for the organs in your torso"
	icon_state = "chest_implant"
	implant_overlay = "chest_implant_overlay"
	parent_organ = "chest"

/obj/item/organ/internal/cyberimp/chest/nutriment
	name = "Nutriment pump implant"
	desc = "This implant with synthesize and pump into your bloodstream a small amount of nutriment when you are starving."
	icon_state = "chest_implant"
	implant_color = "#00AA00"
	var/hunger_threshold = 150
	var/synthesizing = 0
	var/poison_amount = 5
	slot = "stomach"
	origin_tech = "materials=5;programming=3;biotech=4"

/obj/item/organ/internal/cyberimp/chest/nutriment/on_life()
	if(!owner)
		return
	if(synthesizing)
		return
	if(owner.stat == DEAD)
		return
	if(owner.nutrition <= hunger_threshold)
		synthesizing = 1
		to_chat(owner, "<span class='notice'>You feel less hungry...</span>")
		owner.nutrition += 50
		spawn(50)
			synthesizing = 0

/obj/item/organ/internal/cyberimp/chest/nutriment/emp_act(severity)
	if(!owner)
		return
	owner.reagents.add_reagent("????",poison_amount / severity) //food poisoning
	to_chat(owner, "<span class='warning'>You feel like your insides are burning.</span>")

/obj/item/organ/internal/cyberimp/chest/nutriment/plus
	name = "Nutriment pump implant PLUS"
	desc = "This implant will synthesize and pump into your bloodstream a small amount of nutriment when you are hungry."
	icon_state = "chest_implant"
	implant_color = "#006607"
	hunger_threshold = 300
	poison_amount = 10
	origin_tech = "materials=5;programming=3;biotech=5"

/obj/item/organ/internal/cyberimp/chest/reviver
	name = "Reviver implant"
	desc = "This implant will attempt to revive you if you lose consciousness. For the faint of heart!"
	icon_state = "chest_implant"
	implant_color = "#AD0000"
	origin_tech = "materials=6;programming=3;biotech=6;syndicate=4"
	slot = "heartdrive"
	var/revive_cost = 0
	var/reviving = 0
	var/cooldown = 0

/obj/item/organ/internal/cyberimp/chest/reviver/on_life()
	if(reviving)
		if(owner.stat == UNCONSCIOUS)
			spawn(30)
				if(prob(90) && owner.getOxyLoss())
					owner.adjustOxyLoss(-3)
					revive_cost += 5
				if(prob(75) && owner.getBruteLoss())
					owner.adjustBruteLoss(-1)
					revive_cost += 20
				if(prob(75) && owner.getFireLoss())
					owner.adjustFireLoss(-1)
					revive_cost += 20
				if(prob(40) && owner.getToxLoss())
					owner.adjustToxLoss(-1)
					revive_cost += 50
		else
			cooldown = revive_cost + world.time
			reviving = 0
		return
	if(cooldown > world.time)
		return
	if(owner.stat != UNCONSCIOUS)
		return
	if(owner.suiciding)
		return
	revive_cost = 0
	reviving = 1

/obj/item/organ/internal/cyberimp/chest/reviver/emp_act(severity)
	if(!owner)
		return
	if(reviving)
		revive_cost += 200
	else
		cooldown += 200
	if(istype(owner, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = owner
		if(H.stat != DEAD && prob(50 / severity))
			H.heart_attack = 1
			spawn(600 / severity)
				H.heart_attack = 0
				if(H.stat == CONSCIOUS)
					to_chat(H, "<span class='notice'>You feel your heart beating again!</span>")

//ARM...THAT GO IN THE CHEST
/obj/item/organ/internal/cyberimp/chest/arm_mod//dummy parent item for making arm-mod implants. works best with nodrop items that are sent to nullspace upon being dropped.
	name = "Arm-mounted item implant"
	desc = "You shouldn't see this! Adminhelp and report this as an issue on github!"
	icon_state = "chest_implant"
	implant_color = "#007ACC"
	slot = "shoulders"
	origin_tech = "materials=5;biotech=4;powerstorage=4"
	actions_types = list(/datum/action/item_action/organ_action/toggle)
	var/obj/holder//is defined as the retractable item itself. ensure this is defined somewhere!
	var/out = 0//determines if the item is in the owner's hand or not
	var/overloaded = 0//is set to 1 when owner gets EMPed. if set to 1, implant doesn't work.
	var/lasthand = null

/obj/item/organ/internal/cyberimp/chest/arm_mod/ui_action_click()
	if(overloaded)//ensure the implant isn't broken
		to_chat(owner, "<span class='warning'>The implant doesn't respond. It seems to be broken...</span>")
		return
	if(out)//check if the owner has the item out already
		owner.unEquip(holder, 1)//if he does, take it away. then,
		holder.loc = null//stash it in nullspace
		out = 0//and set this to clarify the item isn't out.
		owner.visible_message("<span class='notice'>[owner] retracts [holder].</span>","<span class='notice'>You retract [holder].</span>")
		playsound(get_turf(owner), 'sound/mecha/mechmove03.ogg', 50, 1)
	else//if he doesn't have the item out
		if(owner.put_in_hands(holder))//put it in his hands.
			lasthand = owner.get_active_hand()
			out = 1
			owner.visible_message("<span class='notice'>[owner] extends [holder]!</span>","<span class='notice'>You extend [holder]!</span>")
			playsound(get_turf(owner), 'sound/mecha/mechmove03.ogg', 50, 1)
		else//if this fails to put the item in his hands,
			holder.loc = null//keep it in nullspace
			to_chat(owner, "<span class='warning'>You can't extend [holder] if you can't use your hands!</span>")

/obj/item/organ/internal/cyberimp/chest/arm_mod/emp_act(severity)//if the implant gets EMPed...
	if(!owner || overloaded)//ensure that it's in an owner and that it's not already EMPed, then...
		return
	if(out)//check if he has the item out...
		owner.unEquip(holder, 1)//if he does, take it away.
		holder.loc = null
		out = 0
		owner.visible_message("<span class='notice'>[holder] forcibly retracts into [owner]'s arm.</span>")
	owner.visible_message("<span class='danger'>A loud bang comes from [owner]...</span>")
	playsound(get_turf(owner), 'sound/effects/bang.ogg', 100, 1)
	to_chat(owner, "<span class='warning'>You feel an explosion erupt inside you as your chest implant breaks. Is it hot in here?</span>")
	owner.adjust_fire_stacks(20)
	owner.IgniteMob()//ignite the owner, as well as
	owner.say("AUUUUUUUUUUUUUUUUUUGH!!")
	if(prob(50))
		if(lasthand == "r_hand")
			var/obj/item/organ/external/limb = owner.get_organ("r_arm")
			limb.droplimb(0, DROPLIMB_EDGE)
		else if(lasthand == "l_hand")
			var/obj/item/organ/external/limb = owner.get_organ("l_arm")
			limb.droplimb(0, DROPLIMB_EDGE)
		owner.say("I HAVE BEEN DISARMED!!!")
	owner.adjustFireLoss(25)//severely injure him!
	overloaded = 1//then make sure this can't happen again by breaking the implant.

/obj/item/organ/internal/cyberimp/chest/arm_mod/tase//mounted, self-charging taser!
	name = "Arm-cannon taser implant"
	desc = "A variant of the arm cannon implant that fires electrodes and disabler shots. The cannon emerges from the subject's arms and remains in the shoulders when not in use."
	icon_state = "armcannon_tase_implant"
	origin_tech = "materials=5;combat=5;biotech=4;powerstorage=4"
	actions_types = list(/datum/action/item_action/organ_action/toggle)

/obj/item/organ/internal/cyberimp/chest/arm_mod/tase/New()//when the implant is created...
	holder = new /obj/item/weapon/gun/energy/gun/advtaser/mounted(src)//assign a brand new item to it. (in this case, a gun)

/obj/item/organ/internal/cyberimp/chest/arm_mod/lase//mounted, self-charging laser!
	name = "Arm-cannon laser implant"
	desc = "A variant of the arm cannon implant that fires lethal laser beams. The cannon emerges from the subject's arms and remains in the shoulders when not in use."
	icon_state = "armcannon_lase_implant"
	origin_tech = "materials=5;combat=5;biotech=4;powerstorage=4;syndicate=5"//this is kinda nutty and i might lower it
	actions_types = list(/datum/action/item_action/organ_action/toggle)

/obj/item/organ/internal/cyberimp/chest/arm_mod/lase/New()
	holder = new /obj/item/weapon/gun/energy/laser/mounted(src)

//BOX O' IMPLANTS

/obj/item/weapon/storage/box/cyber_implants
	name = "boxed cybernetic implant"
	desc = "A sleek, sturdy box."
	icon_state = "cyber_implants"

/obj/item/weapon/storage/box/cyber_implants/New(loc, implant)
	..()
	new /obj/item/device/autoimplanter(src)
	if(ispath(implant))
		new implant(src)

/obj/item/weapon/storage/box/cyber_implants/bundle
	name = "boxed cybernetic implants"
	var/list/boxed = list(/obj/item/organ/internal/cyberimp/eyes/xray,/obj/item/organ/internal/cyberimp/eyes/thermals,
						/obj/item/organ/internal/cyberimp/brain/anti_stun, /obj/item/organ/internal/cyberimp/chest/reviver)
	var/amount = 5

/obj/item/weapon/storage/box/cyber_implants/bundle/New()
	..()
	var/implant
	while(contents.len <= amount + 1) // +1 for the autoimplanter.
		implant = pick(boxed)
		new implant(src)
