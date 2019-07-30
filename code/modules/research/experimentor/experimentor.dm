#define SCANTYPE_POKE 1
#define SCANTYPE_IRRADIATE 2
#define SCANTYPE_GAS 3
#define SCANTYPE_HEAT 4
#define SCANTYPE_COLD 5
#define SCANTYPE_OBLITERATE 6
#define SCANTYPE_DISCOVER 7
#define SCANTYPE_RECYCLE 8

#define RARITY_COMMON 0
#define RARITY_UNCOMMON 1
#define RARITY_RARE 2
#define RARITY_VERYRARE 3

/////////////////////////EXPERI-MENTOR DEFINITION/////////////////////////////
//
//
//

/obj/machinery/r_n_d/experimentor
	name = "E.X.P.E.R.I-MENTOR"
	icon = 'icons/obj/machines/heavy_lathe.dmi'
	desc = "A marvel of technology, the onboard AI is capable of turning compatible material into brand-new contraptions... sometimes."
	icon_state = "h_lathe"
	var/list/allowedobjects = list(/obj/item/discovered_tech, /obj/item/unknown_tech)
	density = 1
	anchored = 1
	use_power = IDLE_POWER_USE
	var/base_flex_cost = 10
	var/precise_scanner = 0
	var/spareparts = 0
	var/datum/experimentor/loot_definer/LootDefiner = new/datum/experimentor/loot_definer()

/obj/machinery/r_n_d/experimentor/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/experimentor(src)
	component_parts += new /obj/item/stock_parts/scanning_module(src)
	component_parts += new /obj/item/stock_parts/manipulator(src)
	component_parts += new /obj/item/stock_parts/manipulator(src)
	component_parts += new /obj/item/stock_parts/micro_laser(src)
	component_parts += new /obj/item/stock_parts/micro_laser(src)
	RefreshParts()

// Max part rating count is 12 for a max reduction of 4 flex.
/obj/machinery/r_n_d/experimentor/RefreshParts()
	var/part_rating_count = -4
	base_flex_cost = 10
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		part_rating_count += M.rating
	for(var/obj/item/stock_parts/micro_laser/M in component_parts)
		part_rating_count += M.rating
	for(var/obj/item/stock_parts/scanning_module/M in component_parts)
		precise_scanner = M.rating
	base_flex_cost -= round(part_rating_count/3,1)

/obj/machinery/r_n_d/experimentor/attackby(obj/item/O, mob/user, params)
	if(shocked)
		shock(user,50)

	if(default_deconstruction_screwdriver(user, "h_lathe_maint", "h_lathe", O))
		return

	if(exchange_parts(user, O))
		return

	if(panel_open && istype(O, /obj/item/crowbar))
		default_deconstruction_crowbar(O)
		return

	if(disabled)
		return

	if(loaded_item)
		to_chat(user, "<span class='warning'>The [src] is already loaded.</span>")
		return

	if(O != null && (istype(O, /obj/item/unknown_tech) || istype(O, /obj/item/discovered_tech)))
		if(!user.drop_item())
			return
		loaded_item = O
		O.loc = src
		to_chat(user, "<span class='notice'>You add the [O.name] to the E.X.P.E.R.I-MENTOR.</span>")
		flick("h_lathe_load", src)
	// Checks the allowedobjects list to determine whether the object is an unboxed one.
	else
		to_chat(user, "<span class='warning'>The E.X.P.E.R.I-MENTOR refuses the [O.name].</span>")
		return
	return

/obj/machinery/r_n_d/experimentor/default_deconstruction_crowbar(obj/item/O)
	ejectItem()
	..(O)

/obj/machinery/r_n_d/experimentor/proc/ejectItem(delete=FALSE)
	if(loaded_item)
		var/turf/dropturf = get_turf(pick(view(1,src)))
		if(!dropturf) //Failsafe to prevent the object being lost in the void forever.
			dropturf = get_turf(src)
		loaded_item.loc = dropturf
		if(delete)
			qdel(loaded_item)
		loaded_item = null

//Returns a string based on the level of the checked stat.
/obj/machinery/r_n_d/experimentor/proc/getvaguestat(var/stat)
	if(stat<21)
		return "Very Low"
	if(stat>20 && stat<41)
		return "Low"
	if(stat>40 && stat<61)
		return "Average"
	if(stat>60 && stat<81)
		return "High"
	if(stat>80)
		return "Very High"

/obj/machinery/r_n_d/experimentor/attack_hand(mob/user)
	user.set_machine(src)
	var/dat = "<center>"
	if(istype(loaded_item, /obj/item/unknown_tech))
		var/obj/item/unknown_tech/T = loaded_item
		dat += "<b>Loaded Item:</b> [T.name]<br>"
		if(precise_scanner>=2)
			dat += "<b>Item Type:</b> [T.containedtype]<br>"
		dat += "<br>"
		if(precise_scanner>=3)
			dat += "<b>Stability:</b> [T.stability]<br>"
			dat += "<b>Potency:</b> [T.potency]<br>"
			dat += "<b>Innovation:</b> [T.innovation]<br>"
			dat += "<b>Flexibility:</b> [T.flexibility]<br>"
		else
			dat += "<b>Stability:</b> [getvaguestat(T.stability)]<br>"
			dat += "<b>Potency:</b> [getvaguestat(T.potency)]<br>"
			dat += "<b>Innovation:</b> [getvaguestat(T.innovation)]<br>"
			dat += "<b>Flexibility:</b> [getvaguestat(T.flexibility)]<br>"

		if(precise_scanner >= 4)
			dat += "<br><b>Odds:</b>"
			dat += "<br>Uncommon: [min(((T.uncommon_weighting*T.innovation/100+1)*T.uncommon_base), 100)]%"
			dat += "<br>Rare: [min(((T.rare_weighting*T.innovation/100+1)*T.rare_base), 100)]%"
			dat += "<br>Very Rare: [min(((T.vrare_weighting*T.innovation/100+1)*T.vrare_base), 100)]%"
			dat += "<br>"

		dat += "<br>Available actions:"
		dat += "<br><b><a href='byond://?src=[UID()];item=\ref[loaded_item];function=[SCANTYPE_POKE]'>Tinker</A></b>"
		dat += "<br><b><a href='byond://?src=[UID()];item=\ref[loaded_item];function=[SCANTYPE_IRRADIATE];'>Invent</A></b>"
		dat += "<br><b><a href='byond://?src=[UID()];item=\ref[loaded_item];function=[SCANTYPE_GAS]'>Conserve</A></b>"
		dat += "<br><b><a href='byond://?src=[UID()];item=\ref[loaded_item];function=[SCANTYPE_HEAT]'>Overclock</A></b>"
		dat += "<br><b><a href='byond://?src=[UID()];item=\ref[loaded_item];function=[SCANTYPE_COLD]'>Cool</A></b><br>"
		dat += "<br><b><a href='byond://?src=[UID()];item=\ref[loaded_item];function=[SCANTYPE_DISCOVER]'>Discover</A></b>"
		dat += "<br><b><a href='byond://?src=[UID()];item=\ref[loaded_item];function=[SCANTYPE_OBLITERATE]'>Scramble</A></b><br>"
		dat += "<br><b><a href='byond://?src=[UID()];function=eject'>Eject</A>"
	else if(loaded_item != null)
		dat += "<b>Loaded Item:</b> [loaded_item.name]<br>"
		dat += "<br>Available actions:"
		dat += "<br><b><a href='byond://?src=[UID()];item=\ref[loaded_item];function=[SCANTYPE_RECYCLE]'>Recycle</A></b><br>"
		dat += "<br><b><a href='byond://?src=[UID()];function=eject'>Eject</A>"
	else
		dat += "<b>Nothing loaded.</b>"
	dat += "<br><a href='byond://?src=[UID()];function=refresh'>Refresh</A><br>"
	dat += "<br><a href='byond://?src=[UID()];close=1'>Close</A><br></center>"
	var/datum/browser/popup = new(user, "experimentor","Experimentor", 500, 700, src)
	popup.set_content(dat)
	popup.open()
	onclose(user, "experimentor")

/obj/machinery/r_n_d/experimentor/Topic(href, href_list)
	var/obj/item/unknown_tech/T = locate(href_list["item"]) in src
	if(..())
		return
	usr.set_machine(src)

	var/scantype = href_list["function"]
	if(href_list["close"])
		usr << browse(null, "window=experimentor")
		return
	else if(scantype == "eject")
		ejectItem()
	else if(scantype == "refresh")
		src.updateUsrDialog()
	else
		if(!loaded_item)
			updateUsrDialog() //Set the interface to unloaded mode
			to_chat(usr, "<span class='warning'>[src] is not currently loaded!</span>")
			return
		//It's harder to raise innovation.
		var/adjusted_flex_cost = base_flex_cost - (round(T.stability/20,1)-2)
		if(text2num(scantype) == SCANTYPE_POKE)
			T.adjuststability(rand(2,10))
			T.adjustinnovation(-rand(0,6))
			T.adjustflexibility(-rand(adjusted_flex_cost, adjusted_flex_cost + 5))
			to_chat(usr, "<span class='notice'>Mechanical arms carefully grease and work the [T.name] as lasers prune away excess weight.</span>")
			playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
		if(text2num(scantype) == SCANTYPE_IRRADIATE)
			T.adjustinnovation(rand(2,6))
			T.adjuststability(-rand(0,4))
			T.adjustpotency(-rand(0,4))
			T.adjustflexibility(-rand(adjusted_flex_cost, adjusted_flex_cost + 5))
			to_chat(usr, "<span class='notice'>The E.X.P.E.R.I-MENTOR removes a single part from the [T.name], replacing it with a different one.</span>")
			playsound(src.loc, 'sound/weapons/gun_interactions/pistol_magin.ogg', 50, 1)
		if(text2num(scantype) == SCANTYPE_GAS)
			T.adjustpotency(rand(2,10))
			T.adjustinnovation(-rand(0,6))
			T.adjustflexibility(-rand(adjusted_flex_cost, adjusted_flex_cost + 5))
			to_chat(usr, "<span class='notice'>The E.X.P.E.R.I-MENTOR replaces some of the more delicate components in the [T.name] with more rugged equivalents.</span>")
			playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
		if(text2num(scantype) == SCANTYPE_HEAT)
			T.adjustpotency(rand(2,8))
			T.adjuststability(-rand(0,6))
			T.adjustflexibility(-rand(adjusted_flex_cost, adjusted_flex_cost + 5))
			to_chat(usr, "<span class='notice'>The [T.name] glows ever so slightly as its core clock speed increases.</span>")
			playsound(loc, "sparks", 75, 1, -1)
		if(text2num(scantype) == SCANTYPE_COLD)
			T.adjuststability(rand(2,8))
			T.adjustpotency(-rand(0,6))
			T.adjustflexibility(-rand(adjusted_flex_cost, adjusted_flex_cost + 5))
			to_chat(usr, "<span class='notice'>The E.X.P.E.R.I-MENTOR adds a new coolant cell and some tubing to the [T.name].</span>")
			playsound(loc, 'sound/items/welder.ogg', 50, 1)
		if(text2num(scantype) == SCANTYPE_DISCOVER)
			loaded_item = discover(T)
			ejectItem()
			to_chat(usr, "<span class='notice'>The E.X.P.E.R.I-MENTOR assembles the [T.name] into its new, final form!</span>")
			playsound(src.loc, 'sound/items/rped.ogg', 50, 1)
		if(text2num(scantype) == SCANTYPE_OBLITERATE)
			T.reroll()
			T.adjustflexibility(-5+rand(adjusted_flex_cost*2, adjusted_flex_cost*3))
			to_chat(usr, "<span class='notice'>The [T.name] is carefully taken apart and reassembled in a brand-new configuration by the tiny manipulators.</span>")
			playsound(src.loc, 'sound/items/rped.ogg', 50, 1)
		if(text2num(scantype) == SCANTYPE_RECYCLE)
			ejectItem(TRUE)
			playsound(loc, 'sound/effects/splat.ogg', 50, 1)
			to_chat(usr, "<span class='notice'>The [T.name] is sliced apart by the laser grid and the parts are stored away.</span>")
			spareparts += 50
		use_power(750)
		//If an adjustment takes flexibility to 0, the tech is destroyed.
		if(istype(loaded_item, /obj/item/unknown_tech))
			if(T.flexibility == 0)
				ejectItem(TRUE)
				to_chat(usr, "<span class='warning'>The [T.name] cannot handle the adjustment and breaks apart!</span>")
				playsound(loc, 'sound/effects/splat.ogg', 50, 1)
				criticalfailure()
		if(spareparts >= 100)
			to_chat(usr, "<span class='notice'>The E.X.P.E.R.I-MENTOR beeps and assembles a new prototype from the spare parts reserve!</span>")
			playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)
			loaded_item = new/obj/item/unknown_tech/proto_tech()
			spareparts -= 100
			ejectItem()
	src.updateUsrDialog()
	return

/obj/machinery/r_n_d/experimentor/proc/criticalfailure()
	switch(rand(1,10))
		if(1)
			visible_message("<span class='danger'>Nearby people are hit by debris!</span>")
			for(var/mob/living/m in oview(1, src))
				m.apply_damage(15,BRUTE,pick("head","chest","groin"))
		if(2)
			visible_message("<span class='danger'>The casing cracks, leaking radiation!</span>")
			for(var/mob/living/m in oview(1, src))
				m.apply_effect(25,IRRADIATE)
		if(3)
			visible_message("<span class='warning'>The destroyed artifact releases toxic waste!</span>")
			for(var/turf/T in oview(1, src))
				if(!T.density)
					var/obj/effect/decal/cleanable/reagentdecal = new/obj/effect/decal/cleanable/greenglow(T)
					reagentdecal.reagents.add_reagent("radium", 7)
		if(4)
			visible_message("<span class='warning'>The air crackles and pulses with energy!</span>")
			empulse(src.loc, 4, 0)
		if(5)
			var/turf/start = get_turf(src)
			var/mob/M = locate(/mob/living) in view(src, 3)
			var/turf/MT = get_turf(M)
			if(MT)
				visible_message("<span class='danger'>The coolant cells burst violently!</span>")
				var/obj/item/projectile/magic/fireball/FB = new /obj/item/projectile/magic/fireball(start)
				FB.original = MT
				FB.current = start
				FB.yo = MT.y - start.y
				FB.xo = MT.x - start.x
				FB.fire()
		if(6)
			visible_message("<span class='danger'>The damaged device opens a rift in space, vanishing through it!</span>")
			playsound(src.loc, 'sound/effects/supermatter.ogg', 50, 1, -3)
			for(var/atom/movable/AM in oview(7,src))
				if(!AM.anchored)
					spawn(0)
						AM.throw_at(src,10,1)
		if(7)
			var/mobtype = pick(/mob/living/simple_animal/hostile/bear,/mob/living/simple_animal/hostile/poison/bees,/mob/living/simple_animal/hostile/carp,/mob/living/simple_animal/pet/pug)
			new mobtype(get_turf(src))
			visible_message("<span class='danger'>The damaged device opens a rift in space, and something falls out!</span>")



// Responsible for generating and returning a new functional object to replace the old box.
/obj/machinery/r_n_d/experimentor/proc/discover(var/obj/item/unknown_tech/T)
	//Rarity Roll - Starts common. Better tiers overwrite if they crop up.
	var/rarity = RARITY_COMMON
	if(prob((T.uncommon_weighting*T.innovation/100+1)*T.uncommon_base))
		rarity = RARITY_UNCOMMON
	if(prob((T.rare_weighting*T.innovation/100+1)*T.rare_base))
		rarity = RARITY_RARE
	if(prob((T.vrare_weighting*T.innovation/100+1)*T.vrare_base))
		rarity = RARITY_VERYRARE

	return LootDefiner.define(T.stability, T.potency, T.unpacked_name, rarity, T.containedtype)

#undef SCANTYPE_POKE
#undef SCANTYPE_IRRADIATE
#undef SCANTYPE_GAS
#undef SCANTYPE_HEAT
#undef SCANTYPE_COLD
#undef SCANTYPE_OBLITERATE
#undef SCANTYPE_DISCOVER
#undef SCANTYPE_RECYCLE

#undef RARITY_COMMON
#undef RARITY_UNCOMMON
#undef RARITY_RARE
#undef RARITY_VERYRARE
