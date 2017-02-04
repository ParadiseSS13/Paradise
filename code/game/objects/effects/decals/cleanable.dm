/obj/effect/decal/cleanable
	var/list/random_icon_states = list()
	var/targeted_by = null			// Used so cleanbots can't claim a mess.
	var/noscoop = 0   //if it has this, don't let it be scooped up
	var/noclear = 0    //if it has this, don't delete it when its' scooped up
	var/blood_state = "" //relates to icon mostly
	var/bloodiness = 0 //0-100, amount of blood in this decal, used for making footprints and affecting the alpha of bloody footprints

/obj/effect/decal/cleanable/New()
	if(random_icon_states && length(src.random_icon_states) > 0)
		src.icon_state = pick(src.random_icon_states)
	create_reagents(100)
	..()

/obj/effect/decal/cleanable/attackby(obj/item/weapon/W as obj, mob/user as mob,)
	if(istype(W, /obj/item/weapon/reagent_containers/glass) || istype(W, /obj/item/weapon/reagent_containers/food/drinks))
		if(src.reagents && W.reagents && !noscoop)
			if(!src.reagents.total_volume)
				to_chat(user, "<span class='notice'>There isn't enough [src] to scoop up!</span>")
				return
			if(W.reagents.total_volume >= W.reagents.maximum_volume)
				to_chat(user, "<span class='notice'>[W] is full!</span>")
				return
			to_chat(user, "<span class='notice'>You scoop the [src] into [W]!</span>")
			reagents.trans_to(W, reagents.total_volume)
			if(!reagents.total_volume && !noclear) //scooped up all of it
				qdel(src)
				return
	if(is_hot(W)) //todo: make heating a reagent holder proc
		if(istype(W, /obj/item/clothing/mask/cigarette)) return
		else
			src.reagents.chem_temp += 15
			src.reagents.handle_reactions()
			to_chat(user, "<span class='notice'>You heat [src] with [W]!</span>")

/obj/effect/decal/cleanable/ex_act()
	if(reagents)
		for(var/datum/reagent/R in reagents.reagent_list)
			R.on_ex_act()
	..()

/obj/effect/decal/cleanable/fire_act()
	if(reagents)
		reagents.chem_temp += 30
		reagents.handle_reactions()
	..()

//Add "bloodiness" of this blood's type, to the human's shoes
/obj/effect/decal/cleanable/Crossed(atom/movable/O)
	if(ishuman(O))
		var/mob/living/carbon/human/H = O
		var/obj/item/organ/external/l_foot = H.get_organ("l_foot")
		var/obj/item/organ/external/r_foot = H.get_organ("r_foot")
		var/hasfeet = 1
		if((!l_foot || l_foot.status & ORGAN_DESTROYED) && (!r_foot || r_foot.status & ORGAN_DESTROYED))
			hasfeet = 0
		if(H.shoes && blood_state && bloodiness)
			var/obj/item/clothing/shoes/S = H.shoes
			var/add_blood = 0
			if(bloodiness >= BLOOD_GAIN_PER_STEP)
				add_blood = BLOOD_GAIN_PER_STEP
			else
				add_blood = bloodiness
			bloodiness -= add_blood
			S.bloody_shoes[blood_state] = min(MAX_SHOE_BLOODINESS,S.bloody_shoes[blood_state]+add_blood)
			if(blood_DNA && blood_DNA.len)
				S.add_blood(blood_DNA)
			S.blood_state = blood_state
			update_icon()
			H.update_inv_shoes()
		else if(hasfeet)//Or feet //This will need to be changed.
			H.track_blood = min(MAX_SHOE_BLOODINESS)
			if(!H.feet_blood_DNA)
				H.feet_blood_DNA = list()
			H.feet_blood_DNA |= blood_DNA.Copy()
			update_icon()
			H.update_inv_shoes()