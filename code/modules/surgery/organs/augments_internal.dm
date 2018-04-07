#define STUN_SET_AMOUNT	2

/obj/item/organ/internal/cyberimp
	name = "cybernetic implant"
	desc = "a state-of-the-art implant that improves a baseline's functionality"
	status = ORGAN_ROBOT
	var/implant_color = "#FFFFFF"
	var/implant_overlay
	tough = TRUE // Immune to damage
	sterile = TRUE // Doesn't accumulate germs
	robotic = 2 // these are cybernetic after all

/obj/item/organ/internal/cyberimp/New(var/mob/M = null)
	. = ..()
	if(implant_overlay)
		var/image/overlay = new /image(icon, implant_overlay)
		overlay.color = implant_color
		overlays |= overlay

/obj/item/organ/internal/cyberimp/emp_act()
	return // These shouldn't be hurt by EMPs in the standard way

//[[[[BRAIN]]]]

/obj/item/organ/internal/cyberimp/brain
	name = "cybernetic brain implant"
	desc = "injectors of extra sub-routines for the brain"
	icon_state = "brain_implant"
	implant_overlay = "brain_implant_overlay"
	parent_organ = "head"

/obj/item/organ/internal/cyberimp/brain/emp_act(severity)
	if(!owner || emp_proof)
		return
	var/stun_amount = 5 + (severity-1 ? 0 : 5)
	owner.Stun(stun_amount)
	to_chat(owner, "<span class='warning'>Your body seizes up!</span>")
	return stun_amount


/obj/item/organ/internal/cyberimp/brain/anti_drop
	name = "Anti-drop implant"
	desc = "This cybernetic brain implant will allow you to force your hand muscles to contract, preventing item dropping. Twitch ear to toggle."
	var/active = 0
	var/list/hand_ignore = null
	var/list/obj/item/hand_objs = null
	implant_color = "#DE7E00"
	slot = "brain_antidrop"
	origin_tech = "materials=4;programming=5;biotech=4"
	actions_types = list(/datum/action/item_action/organ_action/toggle)

/obj/item/organ/internal/cyberimp/brain/anti_drop/ui_action_click()
	active = !active
	var/empty = 1
	if(active)
		hand_objs = owner.held_items
		hand_ignore.len = hand_objs.len
		for(var/i in 1 to hand_objs.len)
			if(hand_objs[i])
				empty = 0
				var/obj/item/I = owner.held_items[i]
				if(I.flags & NODROP)
					hand_ignore[i] = 1
				else
					I.flags |= NODROP
					hand_ignore[i] = 0

		if(empty)
			to_chat(owner, "<span class='notice'>You are not holding any items, your hands relax...</span>")
			active = 0
		else
			var/msg = 0
			for(var/i in 1 to hand_objs.len)
				if(hand_objs[i] && !hand_ignore[i])
					msg += 1

			if(msg < 2)
				to_chat(owner, "<span class='notice'>Your hand's grip tightens.</span>")
			else
				to_chat(owner, "<span class='notice'>Your hand's grips tighten.</span>")
	else
		release_items()
		to_chat(owner, "<span class='notice'>Your hands relax...</span>")
		hand_objs = null

/obj/item/organ/internal/cyberimp/brain/anti_drop/emp_act(severity)
	if(!owner || emp_proof)
		return
	var/range = severity ? 10 : 5
	var/atom/A
	var/list/obj/item/hand_items = owner.held_items

	release_items()
	..()
	for(var/obj/item/I in hand_items)
		if(I)
			A = pick(oview(range))
			I.throw_at(A, range, 2)
			to_chat(owner, "<span class='notice'>Your left arm spasms and throws the [I.name]!</span>")

/obj/item/organ/internal/cyberimp/brain/anti_drop/proc/release_items()
	for(var/i in 1 to hand_objs.len)
		if(!hand_ignore[i] && hand_objs[i] in owner.contents)
			var/obj/item/I = hand_objs[i]
			I.flags ^= NODROP

/obj/item/organ/internal/cyberimp/brain/anti_drop/remove(var/mob/living/carbon/M, special = 0)
	. = ..()
	if(active)
		ui_action_click()


/obj/item/organ/internal/cyberimp/brain/anti_stun
	name = "CNS Rebooter implant"
	desc = "This implant will automatically give you back control over your central nervous system, reducing downtime when stunned."
	implant_color = "#FFFF00"
	slot = "brain_antistun"
	origin_tech = "materials=5;programming=4;biotech=5"

/obj/item/organ/internal/cyberimp/brain/anti_stun/on_life()
	..()
	if(crit_fail)
		return
	if(owner.stunned > STUN_SET_AMOUNT)
		owner.SetStunned(STUN_SET_AMOUNT)
	if(owner.weakened > STUN_SET_AMOUNT)
		owner.SetWeakened(STUN_SET_AMOUNT)

/obj/item/organ/internal/cyberimp/brain/anti_stun/emp_act(severity)
	if(crit_fail || emp_proof)
		return
	crit_fail = 1
	spawn(90 / severity)
		crit_fail = 0


//[[[[MOUTH]]]]
/obj/item/organ/internal/cyberimp/mouth
	parent_organ = "mouth"

/obj/item/organ/internal/cyberimp/mouth/breathing_tube
	name = "breathing tube implant"
	desc = "This simple implant adds an internals connector to your back, allowing you to use internals without a mask and protecting you from being choked."
	icon_state = "implant_mask"
	slot = "breathing_tube"
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "materials=2;biotech=3"

/obj/item/organ/internal/cyberimp/mouth/breathing_tube/emp_act(severity)
	if(emp_proof)
		return
	if(prob(60/severity) && owner)
		to_chat(owner, "<span class='warning'>Your breathing tube suddenly closes!</span>")
		owner.AdjustLoseBreath(2)

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
	var/hunger_threshold = NUTRITION_LEVEL_STARVING
	var/synthesizing = 0
	var/poison_amount = 5
	slot = "stomach"
	origin_tech = "materials=2;powerstorage=2;biotech=2"

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
	if(!owner || emp_proof)
		return
	owner.reagents.add_reagent("????",poison_amount / severity) //food poisoning
	to_chat(owner, "<span class='warning'>You feel like your insides are burning.</span>")

/obj/item/organ/internal/cyberimp/chest/nutriment/plus
	name = "Nutriment pump implant PLUS"
	desc = "This implant will synthesize and pump into your bloodstream a small amount of nutriment when you are hungry."
	icon_state = "chest_implant"
	implant_color = "#006607"
	hunger_threshold = NUTRITION_LEVEL_HUNGRY
	poison_amount = 10
	origin_tech = "materials=4;powerstorage=3;biotech=3"

/obj/item/organ/internal/cyberimp/chest/reviver
	name = "Reviver implant"
	desc = "This implant will attempt to revive you if you lose consciousness. For the faint of heart!"
	icon_state = "chest_implant"
	implant_color = "#AD0000"
	origin_tech = "materials=5;programming=4;biotech=4"
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
	if(!owner || emp_proof)
		return
	if(reviving)
		revive_cost += 200
	else
		cooldown += 200
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		if(H.stat != DEAD && prob(50 / severity))
			H.set_heartattack(TRUE)
			spawn(600 / severity)
				H.set_heartattack(FALSE)
				if(H.stat == CONSCIOUS)
					to_chat(H, "<span class='notice'>You feel your heart beating again!</span>")

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
