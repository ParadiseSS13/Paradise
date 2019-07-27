#define SCANTYPE_POKE 1
#define SCANTYPE_IRRADIATE 2
#define SCANTYPE_GAS 3
#define SCANTYPE_HEAT 4
#define SCANTYPE_COLD 5
#define SCANTYPE_OBLITERATE 6
#define SCANTYPE_DISCOVER 7

/////////////////////////EXPERI-MENTOR DEFINITION/////////////////////////////
//
//
//

/obj/machinery/r_n_d/experimentor
	name = "E.X.P.E.R.I-MENTOR"
	icon = 'icons/obj/machines/heavy_lathe.dmi'
	desc = "A marvel of technology, the onboard AI is capable of turning compatible material into brand-new contraptions... sometimes."
	icon_state = "h_lathe"
	density = 1
	anchored = 1
	use_power = IDLE_POWER_USE
	var/base_flex_cost = 10
	var/precise_scanner = 0

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

	if(istype(O, /obj/item/unknown_tech))
		if(!user.drop_item())
			return
		loaded_item = O
		O.loc = src
		to_chat(user, "<span class='notice'>You add the [O.name] to the E.X.P.E.R.I-MENTOR.</span>")
		flick("h_lathe_load", src)
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
	if (stat<21)
		return "Very Low"
	if (stat>20 && stat<41)
		return "Low"
	if (stat>40 && stat<61)
		return "Average"
	if (stat>60 && stat<81)
		return "High"
	if (stat>80)
		return "Very High"

/obj/machinery/r_n_d/experimentor/attack_hand(mob/user)
	user.set_machine(src)
	var/dat = "<center>"
	if(istype(loaded_item, /obj/item/unknown_tech))
		var/obj/item/unknown_tech/T = loaded_item
		dat += "<b>Loaded Item:</b> [T.name]<br>"
		if (precise_scanner>=2)
			dat += "<b>Item Type:</b> [T.containedtype]<br>"
		dat += "<br>"
		if (precise_scanner==4)
			dat += "<b>Stability:</b> [T.stability]<br>"
			dat += "<b>Potency:</b> [T.potency]<br>"
			dat += "<b>Innovation:</b> [T.innovation]<br>"
			dat += "<b>Flexibility:</b> [T.flexibility]<br>"
		else
			dat += "<b>Stability:</b> [getvaguestat(T.stability)]<br>"
			dat += "<b>Potency:</b> [getvaguestat(T.potency)]<br>"
			dat += "<b>Innovation:</b> [getvaguestat(T.innovation)]<br>"
			dat += "<b>Flexibility:</b> [getvaguestat(T.flexibility)]<br>"

		dat += "<br>Available tests:"
		dat += "<br><b><a href='byond://?src=[UID()];item=\ref[loaded_item];function=[SCANTYPE_POKE]'>Tinker</A></b>"
		dat += "<br><b><a href='byond://?src=[UID()];item=\ref[loaded_item];function=[SCANTYPE_IRRADIATE];'>Invent</A></b>"
		dat += "<br><b><a href='byond://?src=[UID()];item=\ref[loaded_item];function=[SCANTYPE_GAS]'>Conserve</A></b>"
		dat += "<br><b><a href='byond://?src=[UID()];item=\ref[loaded_item];function=[SCANTYPE_HEAT]'>Overclock</A></b>"
		dat += "<br><b><a href='byond://?src=[UID()];item=\ref[loaded_item];function=[SCANTYPE_COLD]'>Cool</A></b><br>"
		dat += "<br><b><a href='byond://?src=[UID()];item=\ref[loaded_item];function=[SCANTYPE_DISCOVER]'>Discover</A></b>"
		dat += "<br><b><a href='byond://?src=[UID()];item=\ref[loaded_item];function=[SCANTYPE_OBLITERATE]'>Scramble</A></b><br>"
		dat += "<br><b><a href='byond://?src=[UID()];function=eject'>Eject</A>"
	else
		dat += "<b>Nothing loaded.</b>"
	dat += "<br><a href='byond://?src=[UID()];function=refresh'>Refresh</A><br>"
	dat += "<br><a href='byond://?src=[UID()];close=1'>Close</A><br></center>"
	var/datum/browser/popup = new(user, "experimentor","Experimentor", 700, 400, src)
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
		// Balanced assuming an average of ~5 actions, growing to ~10 with upgrade level. It's harder to raise innovation.
		var/adjusted_flex_cost = base_flex_cost - (round(T.stability/20,1)-2)
		if(text2num(scantype) == SCANTYPE_POKE)
			T.adjuststability(rand(2,10))
			T.adjustinnovation(0-rand(0,6))
			T.adjustflexibility(0-rand(adjusted_flex_cost, adjusted_flex_cost + 5))
			to_chat(usr, "<span class='notice'>Mechanical arms carefully grease and work the [T.name] as lasers prune away excess weight.</span>")
			playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
		if(text2num(scantype) == SCANTYPE_IRRADIATE)
			T.adjustinnovation(rand(2,6))
			T.adjuststability(0-rand(0,4))
			T.adjustpotency(0-rand(0,4))
			T.adjustflexibility(0-rand(adjusted_flex_cost, adjusted_flex_cost + 5))
			to_chat(usr, "<span class='notice'>The E.X.P.E.R.I-MENTOR removes a single part from the [T.name], replacing it with a different one.</span>")
			playsound(src.loc, 'sound/weapons/gun_interactions/pistol_magin.ogg', 50, 1)
		if(text2num(scantype) == SCANTYPE_GAS)
			T.adjustpotency(rand(2,10))
			T.adjustinnovation(0-rand(0,6))
			T.adjustflexibility(0-rand(adjusted_flex_cost, adjusted_flex_cost + 5))
			to_chat(usr, "<span class='notice'>The E.X.P.E.R.I-MENTOR replaces some of the more delicate components in the [T.name] with more rugged equivalents.</span>")
			playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
		if(text2num(scantype) == SCANTYPE_HEAT)
			T.adjustpotency(rand(2,8))
			T.adjuststability(0-rand(0,6))
			T.adjustflexibility(0-rand(adjusted_flex_cost, adjusted_flex_cost + 5))
			to_chat(usr, "<span class='notice'>The [T.name] glows ever so slightly as its core clock speed increases.</span>")
			playsound(loc, "sparks", 75, 1, -1)
		if(text2num(scantype) == SCANTYPE_COLD)
			T.adjuststability(rand(2,8))
			T.adjustpotency(0-rand(0,6))
			T.adjustflexibility(0-rand(adjusted_flex_cost, adjusted_flex_cost + 5))
			to_chat(usr, "<span class='notice'>The E.X.P.E.R.I-MENTOR adds a new coolant cell and some tubing to the [T.name].</span>")
			playsound(loc, 'sound/items/welder.ogg', 50, 1)
		if(text2num(scantype) == SCANTYPE_DISCOVER)
			loaded_item = discover(T)
			ejectItem()
			to_chat(usr, "<span class='notice'>The E.X.P.E.R.I-MENTOR assembles the [T.name] into its new, final form!</span>")
			playsound(src.loc, 'sound/items/rped.ogg', 50, 1)
		if(text2num(scantype) == SCANTYPE_OBLITERATE)
			T.reroll()
			T.adjustflexibility(0-rand(adjusted_flex_cost*2+5, adjusted_flex_cost*3+5))
			to_chat(usr, "<span class='notice'>The [T.name] is carefully taken apart and reassembled in a brand-new configuration by the tiny manipulators.</span>")
			playsound(src.loc, 'sound/items/rped.ogg', 50, 1)
		use_power(750)
		//If an adjustment takes flexibility to 0, the tech is destroyed.
		if(T.flexibility == 0)
			ejectItem(TRUE)
			to_chat(usr, "<span class='warning'>The [T.name] cannot handle the adjustment and shatters!</span>")
			playsound(loc, 'sound/effects/splat.ogg', 50, 1)
	src.updateUsrDialog()
	return

// Responsible for generating and returning a new functional object to replace the old box.
/obj/machinery/r_n_d/experimentor/proc/discover(var/T)
	return T

#undef SCANTYPE_POKE
#undef SCANTYPE_IRRADIATE
#undef SCANTYPE_GAS
#undef SCANTYPE_HEAT
#undef SCANTYPE_COLD
#undef SCANTYPE_OBLITERATE
#undef SCANTYPE_DISCOVER

/////////////////////////MYSTERIOUS TECH DEFINITIONS//////////////////////////
// Strange Objects are replaced by Mysterious Tech, each of which serves
// as a "container" for the expanded relic selection. Each type of container
// has its own rarity and stat ranges which affect the "unboxed" product.
// tech can be "unboxed" by the experimentor, which can also be used to tweak
// the final stats of the object before unboxing.
//
// There are three "primary" stats for each piece of tech that are determined upon generation. Not all
// stats apply to all permutations of an object; high or low stats may not be relevant. If a triphasic
// scanning module is installed, exact stats are shown, otherwise stats are shown on a continuuum from
// very low (less than 20), low (21-40), average (41-60), high (61-80) and very high (80+).
//
// Stability - Determines failure rate of activated objects. Low stability may cause catastrophic failure on activation, destroying the object.
// Potency - How good the object is at doing what it does. Amplifies positive/negative effects.
// Innovation - How likely the object is to be a rarer and more powerful variety.
// Flexibility - The "currency" used to tweak the item's stats in the experimentor. An upgraded experimentor uses slightly less flexibility for each tweak.


/obj/item/unknown_tech
	name = "Unknown Tech"
	desc = "An unknown piece of technology. You get a strong feeling that this a glitch in the universe and shouldn't exist."
	icon = 'icons/obj/assemblies.dmi'
	origin_tech = "combat=1;plasmatech=1;powerstorage=1;materials=1"
	var/unpacked_name = "Unknown"
	var/stability
	var/potency
	var/innovation
	var/flexibility
	var/containedtype
	var/list/typelist = list("Device")
	var/list/iconlist = list("shock_kit","armor-igniter-analyzer","infra-igniter0","infra-igniter1","radio-multitool","prox-radio1","radio-radio","timer-multitool0","radio-igniter-tank")
    // Determines how the base stat bell curve shakes out. Applies to each stat except flexibility, which is linearly distributed between a range.
    // A mean of 50 and a sd of 10 mean that most points will come out around 40-60 and will rarely go between 20-80.
	var/stability_standardeviation = 10
	var/stability_mean = 50
	var/potency_standardeviation = 10
	var/potency_mean = 50
	var/innovation_standardeviation = 10
	var/innovation_mean = 50
	var/flexibility_min = 20
	var/flexibility_max = 100
    // Innovation weight for each rarity tier. a weighting of 3 means each point of innovation adds 3% of the base chance for that tier to the tier's modified chance.
	var/uncommon_weighting = 2
	var/rare_weighting = 2
	var/vrare_weighting = 0.5
    // Base probability percentage for each rarity tier (common rarity is determined by the remainder out of 100%, 80% by default).
	var/uncommon_base = 14
	var/rare_base = 5
	var/vrare_base = 1

// Basically rolls 2d6 to approximate a normal distribution with a standard deviation of sigma and a mean of mu. Rounds to the nearest integer.
/obj/item/unknown_tech/proc/NormDistRand(var/sigma, var/mu)
    var/randroll = (rand(0,100) + rand(0,100) + rand(0,100) + rand(0,100) + rand(0,100) + rand(0,100) + rand(0,100) + rand(0,100) + rand(0,100) + rand(0,100) + rand(0,100) + rand(0,100))
    return round(((randroll-600)*sigma)/100+mu,1)

/obj/item/unknown_tech/New()
	..()
	icon_state = iconlist[rand(0,iconlist.len)]
	containedtype = typelist[rand(0,typelist.len)]
	stability = NormDistRand(stability_standardeviation, stability_mean)
	potency = NormDistRand(potency_standardeviation, potency_mean)
	innovation = NormDistRand(innovation_standardeviation, innovation_mean)
	flexibility = rand(flexibility_min, flexibility_max)

/obj/item/unknown_tech/proc/adjuststability(var/statchange)
	stability += statchange
	if (stability > 100)
		stability = 100
	if (stability < 0)
		stability = 0

/obj/item/unknown_tech/proc/adjustinnovation(var/statchange)
	innovation += statchange
	if (innovation > 100)
		innovation = 100
	if (innovation < 0)
		innovation = 0

/obj/item/unknown_tech/proc/adjustpotency(var/statchange)
	potency += statchange
	if (potency > 100)
		potency = 100
	if (potency < 0)
		potency = 0

/obj/item/unknown_tech/proc/adjustflexibility(var/statchange)
	flexibility += statchange
	if (flexibility > 100)
		flexibility = 100
	if (flexibility < 0)
		flexibility = 0

/obj/item/unknown_tech/proc/reroll()
	icon_state = iconlist[rand(0,iconlist.len)]
	containedtype = typelist[rand(0,typelist.len)]
	stability = NormDistRand(stability_standardeviation, stability_mean)
	potency = NormDistRand(potency_standardeviation, potency_mean)
	innovation = NormDistRand(innovation_standardeviation, innovation_mean)

/obj/item/unknown_tech/proto_tech/
	name = "Prototype Technology"
	desc = "An unknown piece of technology stamped with the NanoTrasen logo. Clearly not production ready, it was probably left by a previous shift."
	unpacked_name = "Prototype"
	icon = 'icons/obj/assemblies.dmi'
	origin_tech = "combat=1;plasmatech=1;powerstorage=1;materials=1"

/obj/item/unknown_tech/myst_tech/
	name = "Mysterious Technology"
	desc = "An unknown piece of technology stamped only with a strange barcode. The tooling is clearly different from in-house."
	unpacked_name = "Mysterious"
	icon = 'icons/obj/assemblies.dmi'
	origin_tech = "combat=1;plasmatech=1;powerstorage=1;materials=1"
	rare_weighting = 4
	vrare_weighting = 2

/obj/item/unknown_tech/alien_tech/
	name = "Alien Technology"
	desc = "An unknown piece of technology stamped with lettering in no recognizable language. The make is unlike any you've ever seen."
	unpacked_name = "Alien"
	icon = 'icons/obj/assemblies.dmi'
	origin_tech = "combat=1;plasmatech=1;powerstorage=1;materials=1"
	rare_weighting = 10
	vrare_weighting = 20











//////////////////////////////////OLD RELICS////////////////////////////////////////

/obj/item/relic
	name = "strange object"
	desc = "What mysteries could this hold?"
	icon = 'icons/obj/assemblies.dmi'
	origin_tech = "combat=1;plasmatech=1;powerstorage=1;materials=1"
	var/realName = "defined object"
	var/revealed = FALSE
	var/realProc
	var/cooldownMax = 60
	var/cooldown
	var/floof

/obj/item/relic/New()
	icon_state = pick("shock_kit","armor-igniter-analyzer","infra-igniter0","infra-igniter1","radio-multitool","prox-radio1","radio-radio","timer-multitool0","radio-igniter-tank")
	realName = "[pick("broken","twisted","spun","improved","silly","regular","badly made")] [pick("device","object","toy","suspicious tech","gear")]"
	floof = pick(/mob/living/simple_animal/pet/corgi, /mob/living/simple_animal/pet/cat, /mob/living/simple_animal/pet/fox, /mob/living/simple_animal/mouse, /mob/living/simple_animal/pet/pug, /mob/living/simple_animal/lizard, /mob/living/simple_animal/diona, /mob/living/simple_animal/butterfly, /mob/living/carbon/human/monkey)


/obj/item/relic/proc/reveal()
	if(revealed) //Re-rolling your relics seems a bit overpowered, yes?
		return
	revealed = TRUE
	name = realName
	cooldownMax = rand(60,300)
	realProc = pick("teleport","explode","rapidDupe","petSpray","flash","clean","floofcannon")
	origin_tech = pick("engineering=[rand(2,5)]","magnets=[rand(2,5)]","plasmatech=[rand(2,5)]","programming=[rand(2,5)]","powerstorage=[rand(2,5)]")

/obj/item/relic/attack_self(mob/user)
	if(revealed)
		if(cooldown)
			to_chat(user, "<span class='warning'>[src] does not react!</span>")
			return
		else if(src.loc == user)
			cooldown = TRUE
			call(src,realProc)(user)
			spawn(cooldownMax)
				cooldown = FALSE
	else
		to_chat(user, "<span class='notice'>You aren't quite sure what to do with this, yet.</span>")

//////////////// RELIC PROCS /////////////////////////////

/obj/item/relic/proc/throwSmoke(turf/where)
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(1,0, where, 0)
	smoke.start()

/obj/item/relic/proc/floofcannon(mob/user)
	playsound(src.loc, "sparks", rand(25,50), 1)
	var/mob/living/C = new floof(get_turf(user))
	C.throw_at(pick(oview(10,user)),10,rand(3,8))
	throwSmoke(get_turf(C))
	warn_admins(user, "Floof Cannon", 0)

/obj/item/relic/proc/clean(mob/user)
	playsound(src.loc, "sparks", rand(25,50), 1)
	var/obj/item/grenade/chem_grenade/cleaner/CL = new/obj/item/grenade/chem_grenade/cleaner(get_turf(user))
	CL.prime()
	warn_admins(user, "Smoke", 0)

/obj/item/relic/proc/flash(mob/user)
	playsound(src.loc, "sparks", rand(25,50), 1)
	var/obj/item/grenade/flashbang/CB = new/obj/item/grenade/flashbang(get_turf(user))
	CB.prime()
	warn_admins(user, "Flash")

/obj/item/relic/proc/petSpray(mob/user)
	var/message = "<span class='danger'>[src] begins to shake, and in the distance the sound of rampaging animals arises!</span>"
	visible_message(message)
	to_chat(user, message)
	var/animals = rand(1,25)
	var/counter
	var/list/valid_animals = list(/mob/living/simple_animal/parrot,/mob/living/simple_animal/butterfly,/mob/living/simple_animal/pet/cat,/mob/living/simple_animal/pet/corgi,/mob/living/simple_animal/crab,/mob/living/simple_animal/pet/fox,/mob/living/simple_animal/lizard,/mob/living/simple_animal/mouse,/mob/living/simple_animal/pet/pug,/mob/living/simple_animal/hostile/bear,/mob/living/simple_animal/hostile/poison/bees,/mob/living/simple_animal/hostile/carp)
	for(counter = 1; counter < animals; counter++)
		var/mobType = pick(valid_animals)
		new mobType(get_turf(src))
	warn_admins(user, "Mass Mob Spawn")
	if(prob(60))
		to_chat(user, "<span class='warning'>[src] falls apart!</span>")
		qdel(src)

/obj/item/relic/proc/rapidDupe(mob/user)
	audible_message("[src] emits a loud pop!")
	var/list/dupes = list()
	var/counter
	var/max = rand(5,10)
	for(counter = 1; counter < max; counter++)
		var/obj/item/relic/R = new src.type(get_turf(src))
		R.name = name
		R.desc = desc
		R.realName = realName
		R.realProc = realProc
		R.revealed = TRUE
		dupes |= R
		spawn()
			R.throw_at(pick(oview(7,get_turf(src))),10,1)
	counter = 0
	spawn(rand(10,100))
		for(counter = 1; counter <= dupes.len; counter++)
			var/obj/item/relic/R = dupes[counter]
			qdel(R)
	warn_admins(user, "Rapid duplicator", 0)

/obj/item/relic/proc/explode(mob/user)
	to_chat(user, "<span class='danger'>[src] begins to heat up!</span>")
	spawn(rand(35,100))
		if(src.loc == user)
			visible_message("<span class='notice'>The [src]'s top opens, releasing a powerful blast!</span>")
			explosion(user.loc, -1, rand(1,5), rand(1,5), rand(1,5), rand(1,5), flame_range = 2)
			warn_admins(user, "Explosion")
			qdel(src) //Comment this line to produce a light grenade (the bomb that keeps on exploding when used)!!

/obj/item/relic/proc/teleport(mob/user)
	to_chat(user, "<span class='notice'>The [src] begins to vibrate!</span>")
	spawn(rand(10,30))
		var/turf/userturf = get_turf(user)
		if(src.loc == user && is_teleport_allowed(userturf.z)) //Because Nuke Ops bringing this back on their shuttle, then looting the ERT area is 2fun4you!
			visible_message("<span class='notice'>The [src] twists and bends, relocating itself!</span>")
			throwSmoke(userturf)
			do_teleport(user, userturf, 8, asoundin = 'sound/effects/phasein.ogg')
			throwSmoke(get_turf(user))
			warn_admins(user, "Teleport", 0)

//Admin Warning proc for relics
/obj/item/relic/proc/warn_admins(mob/user, RelicType, priority = 1)
	var/turf/T = get_turf(src)
	var/log_msg = "[RelicType] relic used by [key_name(user)] in ([T.x],[T.y],[T.z])"
	if(priority) //For truly dangerous relics that may need an admin's attention. BWOINK!
		message_admins("[RelicType] relic activated by [key_name_admin(user)] in ([T.x], [T.y], [T.z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>JMP</a>)",0,1)
	log_game(log_msg)
	investigate_log(log_msg, "experimentor")
