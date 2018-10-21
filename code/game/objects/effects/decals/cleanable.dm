/obj/effect/decal/cleanable
	anchored = TRUE
	var/list/random_icon_states = list()
	var/noscoop = FALSE   //if it has this, don't let it be scooped up
	var/noclear = FALSE    //if it has this, don't delete it when its' scooped up

/obj/effect/decal/cleanable/proc/can_bloodcrawl_in()
	return FALSE

/obj/effect/decal/cleanable/New()
	if(random_icon_states && length(src.random_icon_states) > 0)
		src.icon_state = pick(src.random_icon_states)
	create_reagents(100)
	if(smooth)
		queue_smooth(src)
		queue_smooth_neighbors(src)
	..()

/obj/effect/decal/cleanable/Destroy()
	if(smooth)
		queue_smooth_neighbors(src)
	return ..()

/obj/effect/decal/cleanable/attackby(obj/item/W as obj, mob/user as mob,)
	if(istype(W, /obj/item/reagent_containers/glass) || istype(W, /obj/item/reagent_containers/food/drinks))
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
		if(istype(W, /obj/item/clothing/mask/cigarette))
			return
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
