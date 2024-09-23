//this is designed to replace the destructive analyzer

#define SCANTYPE_POKE 1
#define SCANTYPE_IRRADIATE 2
#define SCANTYPE_GAS 3
#define SCANTYPE_HEAT 4
#define SCANTYPE_COLD 5
#define SCANTYPE_OBLITERATE 6
#define SCANTYPE_DISCOVER 7

#define EFFECT_PROB_VERYLOW 20
#define EFFECT_PROB_LOW 35
#define EFFECT_PROB_MEDIUM 50
#define EFFECT_PROB_HIGH 75
#define EFFECT_PROB_VERYHIGH 95

#define FAIL 8
/obj/machinery/r_n_d/experimentor
	name = "\improper E.X.P.E.R.I-MENTOR"
	icon = 'icons/obj/machines/heavy_lathe.dmi'
	icon_state = "h_lathe"
	density = TRUE
	anchored = TRUE
	power_state = IDLE_POWER_USE
	var/recentlyExperimented = 0
	var/badThingCoeff = 0
	var/resetTime = 15
	var/cloneMode = FALSE
	var/cloneCount = 0
	var/list/item_reactions = list()
	var/list/valid_items = list() //valid items for special reactions like transforming
	var/list/critical_items = list() //items that can cause critical reactions
	var/list/blocked_items = list(/obj/item/reagent_containers/drinks/bottle/dragonsbreath,
									/obj/item/reagent_containers/drinks/bottle/immortality)
	/// Used for linking with rnd consoles
	var/range = 5

/obj/machinery/r_n_d/experimentor/proc/ConvertReqString2List(list/source_list)
	var/list/temp_list = params2list(source_list)
	for(var/O in temp_list)
		temp_list[O] = text2num(temp_list[O])
	return temp_list

/obj/machinery/r_n_d/experimentor/proc/SetTypeReactions()
	var/probWeight = 0
	for(var/I in typesof(/obj/item))
		if(istype(I,/obj/item/relic)) //does istype even work here
			item_reactions["[I]"] = SCANTYPE_DISCOVER
		else
			item_reactions["[I]"] = pick(SCANTYPE_POKE,SCANTYPE_IRRADIATE,SCANTYPE_GAS,SCANTYPE_HEAT,SCANTYPE_COLD,SCANTYPE_OBLITERATE)
		if(ispath(I,/obj/item/stock_parts) || ispath(I,/obj/item/grenade/chem_grenade) || ispath(I,/obj/item/kitchen))
			var/obj/item/tempCheck = I
			if(initial(tempCheck.icon_state) != null) //check it's an actual usable item, in a hacky way
				valid_items += 15
				valid_items += I
				probWeight++

		if(ispath(I,/obj/item/food))
			var/obj/item/tempCheck = I
			if(I in blocked_items)
				continue
			if(initial(tempCheck.icon_state) != null) //check it's an actual usable item, in a hacky way
				valid_items += rand(1,max(2,35-probWeight))
				valid_items += I

		if(ispath(I,/obj/item/rcd) || ispath(I,/obj/item/grenade) || ispath(I,/obj/item/aicard) || ispath(I,/obj/item/storage/backpack/holding) || ispath(I,/obj/item/slime_extract) || ispath(I,/obj/item/onetankbomb) || ispath(I,/obj/item/transfer_valve))
			var/obj/item/tempCheck = I
			if(initial(tempCheck.icon_state) != null)
				critical_items += I

/obj/machinery/r_n_d/experimentor/Initialize(mapload) // DIEEEEEEEEEEEEEEEEEEEEEEE
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/experimentor(src)
	component_parts += new /obj/item/stock_parts/scanning_module(src)
	component_parts += new /obj/item/stock_parts/manipulator(src)
	component_parts += new /obj/item/stock_parts/manipulator(src)
	component_parts += new /obj/item/stock_parts/micro_laser(src)
	component_parts += new /obj/item/stock_parts/micro_laser(src)
	SetTypeReactions()
	RefreshParts()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/r_n_d/experimentor/RefreshParts()
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		if(resetTime > 0 && (resetTime - M.rating) >= 1)
			resetTime -= M.rating
	for(var/obj/item/stock_parts/scanning_module/M in component_parts)
		badThingCoeff += M.rating*2
	for(var/obj/item/stock_parts/micro_laser/M in component_parts)
		badThingCoeff += M.rating

/obj/machinery/r_n_d/experimentor/proc/checkCircumstances(obj/item/O)
	//snowflake check to only take "made" bombs
	if(istype(O,/obj/item/transfer_valve))
		var/obj/item/transfer_valve/T = O
		if(!T.tank_one || !T.tank_two || !T.attached_device)
			return FALSE
	return TRUE

/obj/machinery/r_n_d/experimentor/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/storage/part_replacer))
		return ..()

	if(!checkCircumstances(O))
		to_chat(user, "<span class='warning'>[O] is not yet valid for [src] and must be completed!</span>")
		return

	if(!linked_console)
		to_chat(user, "<span class='warning'>[src] must be linked to an R&D console first!</span>")
		return

	if(loaded_item)
		to_chat(user, "<span class='warning'>[src] is already loaded.</span>")
		return

	if(isitem(O))
		if(!O.origin_tech)
			to_chat(user, "<span class='warning'>This doesn't seem to have a tech origin!</span>")
			return

		var/list/temp_tech = ConvertReqString2List(O.origin_tech)
		if(length(temp_tech) == 0)
			to_chat(user, "<span class='warning'>You cannot experiment on this item!</span>")
			return

		if(!user.drop_item())
			return

		loaded_item = O
		O.loc = src
		to_chat(user, "<span class='notice'>You add [O] to the machine.</span>")
		flick("h_lathe_load", src)

/obj/machinery/r_n_d/experimentor/crowbar_act(mob/user, obj/item/I)
	if(!panel_open)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	ejectItem()
	default_deconstruction_crowbar(user, I)

/obj/machinery/r_n_d/experimentor/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	default_deconstruction_screwdriver(user, "h_lathe_maint", "h_lathe", I)
	if(linked_console)
		linked_console.linked_destroy = null
		linked_console = null

/obj/machinery/r_n_d/experimentor/attack_hand(mob/user)
	if(..())
		return

	interact(user)

/obj/machinery/r_n_d/experimentor/interact(mob/living/carbon/human/user)
	user.set_machine(src)

	var/dat = "<center>"
	if(!linked_console)
		dat += "<b><a href='byond://?src=[UID()];function=search'>Scan for R&D Console</A></b><br>"
	if(loaded_item)
		dat += "<b>Loaded Item:</b> [loaded_item]<br>"
		dat += "<b>Technology</b>:<br>"
		var/list/D = ConvertReqString2List(loaded_item.origin_tech)
		for(var/T in D)
			dat += "[T]<br>"
		dat += "<br><br>Available tests:"
		dat += "<br><b><a href='byond://?src=[UID()];item=\ref[loaded_item];function=[SCANTYPE_POKE]'>Poke</A></b>"
		dat += "<br><b><a href='byond://?src=[UID()];item=\ref[loaded_item];function=[SCANTYPE_IRRADIATE];'>Irradiate</A></b>"
		dat += "<br><b><a href='byond://?src=[UID()];item=\ref[loaded_item];function=[SCANTYPE_GAS]'>Gas</A></b>"
		dat += "<br><b><a href='byond://?src=[UID()];item=\ref[loaded_item];function=[SCANTYPE_HEAT]'>Burn</A></b>"
		dat += "<br><b><a href='byond://?src=[UID()];item=\ref[loaded_item];function=[SCANTYPE_COLD]'>Freeze</A></b>"
		dat += "<br><b><a href='byond://?src=[UID()];item=\ref[loaded_item];function=[SCANTYPE_OBLITERATE]'>Destroy</A></b><br>"
		if(istype(loaded_item,/obj/item/relic))
			dat += "<br><b><a href='byond://?src=[UID()];item=\ref[loaded_item];function=[SCANTYPE_DISCOVER]'>Discover</A></b><br>"
		dat += "<br><b><a href='byond://?src=[UID()];function=eject'>Eject</A>"
	else
		dat += "<b>Nothing loaded.</b>"
	dat += "<br><a href='byond://?src=[UID()];function=refresh'>Refresh</A><br>"
	dat += "<br><a href='byond://?src=[UID()];close=1'>Close</A><br></center>"
	var/datum/browser/popup = new(user, "experimentor","Experimentor", 700, 400)
	popup.set_content(dat)
	popup.open()
	onclose(user, "experimentor")

/obj/machinery/r_n_d/experimentor/proc/matchReaction(matching,reaction)
	var/obj/item/D = matching
	if(D)
		if(item_reactions.Find("[D.type]"))
			var/tor = item_reactions["[D.type]"]
			if(tor == text2num(reaction))
				return tor
			else
				return FAIL
		else
			return FAIL
	else
		return FAIL

/obj/machinery/r_n_d/experimentor/proc/ejectItem(delete=FALSE)
	if(loaded_item)
		if(cloneMode && cloneCount > 0)
			visible_message("<span class='notice'>A duplicate [loaded_item] pops out!</span>")
			var/type_to_make = loaded_item.type
			new type_to_make(get_turf(pick(oview(1,src))))
			--cloneCount
			if(cloneCount == 0)
				cloneMode = FALSE
			return
		var/turf/dropturf = get_turf(pick(view(1,src)))
		if(!dropturf) //Failsafe to prevent the object being lost in the void forever.
			dropturf = get_turf(src)
		loaded_item.loc = dropturf
		if(delete)
			qdel(loaded_item)
		loaded_item = null

/obj/machinery/r_n_d/experimentor/proc/throwSmoke(turf/where)
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(1, FALSE, where)
	smoke.start()

/obj/machinery/r_n_d/experimentor/proc/pickWeighted(list/from)
	var/result = FALSE
	var/counter = 1
	while(!result)
		var/probtocheck = from[counter]
		if(prob(probtocheck))
			result = TRUE
			return from[counter+1]
		if(counter + 2 < length(from))
			counter = counter + 2
		else
			counter = 1

/obj/machinery/r_n_d/experimentor/proc/experiment(exp,obj/item/exp_on)
	recentlyExperimented = 1
	icon_state = "h_lathe_wloop"
	var/chosenchem
	var/criticalReaction = (exp_on.type in critical_items) ? TRUE : FALSE
	////////////////////////////////////////////////////////////////////////////////////////////////
	if(exp == SCANTYPE_POKE)
		visible_message("[src] prods at [exp_on] with mechanical arms.")
		if(prob(EFFECT_PROB_LOW) && criticalReaction)
			visible_message("[exp_on] is gripped in just the right way, enhancing its focus.")
			badThingCoeff++
		if(prob(EFFECT_PROB_VERYLOW-badThingCoeff))
			visible_message("<span class='danger'>[src] malfunctions and destroys [exp_on], lashing its arms out at nearby people!</span>")
			for(var/mob/living/m in oview(1, src))
				m.apply_damage(15,BRUTE,pick("head","chest","groin"))
				investigate_log("Experimentor dealt minor brute to [m].", "experimentor")
			ejectItem(TRUE)
		if(prob(EFFECT_PROB_LOW-badThingCoeff))
			visible_message("<span class='warning'>[src] malfunctions!</span>")
			exp = SCANTYPE_OBLITERATE
		if(prob(EFFECT_PROB_MEDIUM-badThingCoeff))
			visible_message("<span class='danger'>[src] malfunctions, throwing [exp_on]!</span>")
			var/mob/living/target = locate(/mob/living) in oview(7,src)
			if(target)
				var/obj/item/throwing = loaded_item
				investigate_log("Experimentor has thrown [loaded_item] at [target]", "experimentor")
				ejectItem()
				if(throwing)
					throwing.throw_at(target, 10, 1)
	////////////////////////////////////////////////////////////////////////////////////////////////
	if(exp == SCANTYPE_IRRADIATE)
		visible_message("<span class='danger'>[src] reflects radioactive rays at [exp_on]!</span>")
		if(prob(EFFECT_PROB_LOW) && criticalReaction)
			visible_message("[exp_on] has activated an unknown subroutine!")
			cloneMode = TRUE
			cloneCount = badThingCoeff
			investigate_log("Experimentor has made a clone of [exp_on]", "experimentor")
			ejectItem()
		if(prob(EFFECT_PROB_VERYLOW-badThingCoeff))
			visible_message("<span class='danger'>[src] malfunctions, melting [exp_on] and leaking radiation!</span>")
			radiation_pulse(src, 500)
			ejectItem(TRUE)
		if(prob(EFFECT_PROB_LOW-badThingCoeff))
			visible_message("<span class='warning'>[src] malfunctions, spewing toxic waste!</span>")
			for(var/turf/T in oview(1, src))
				if(!T.density)
					if(prob(EFFECT_PROB_VERYHIGH))
						new /obj/effect/decal/cleanable/greenglow(T)
		if(prob(EFFECT_PROB_MEDIUM-badThingCoeff))
			var/savedName = "[exp_on]"
			ejectItem(TRUE)
			var/newPath = pickWeighted(valid_items)
			loaded_item = new newPath(src)
			visible_message("<span class='warning'>[src] malfunctions, transforming [savedName] into [loaded_item]!</span>")
			investigate_log("Experimentor has transformed [savedName] into [loaded_item]", "experimentor")
			if(istype(loaded_item,/obj/item/grenade/chem_grenade))
				var/obj/item/grenade/chem_grenade/CG = loaded_item
				CG.prime()
			ejectItem()
	////////////////////////////////////////////////////////////////////////////////////////////////
	if(exp == SCANTYPE_GAS)
		visible_message("<span class='warning'>[src] fills its chamber with gas, [exp_on] included.</span>")
		if(prob(EFFECT_PROB_LOW) && criticalReaction)
			visible_message("[exp_on] achieves the perfect mix!")
			new /obj/item/stack/sheet/mineral/plasma(get_turf(pick(oview(1,src))))
		if(prob(EFFECT_PROB_VERYLOW-badThingCoeff))
			visible_message("<span class='danger'>[src] destroys [exp_on], leaking dangerous gas!</span>")
			chosenchem = pick("carbon","radium","toxin","condensedcapsaicin","psilocybin","space_drugs","ethanol","beepskysmash")
			var/datum/reagents/R = new/datum/reagents(15)
			R.my_atom = src
			R.add_reagent(chosenchem , 15)
			investigate_log("Experimentor has released [chosenchem] smoke.", "experimentor")
			var/datum/effect_system/smoke_spread/chem/smoke = new
			smoke.set_up(R, src, TRUE)
			playsound(loc, 'sound/effects/smoke.ogg', 50, TRUE, -3)
			smoke.start()
			qdel(R)
			ejectItem(TRUE)
		if(prob(EFFECT_PROB_VERYLOW-badThingCoeff))
			visible_message("<span class='danger'>[src]'s chemical chamber has sprung a leak!</span>")
			chosenchem = pick("mutationtoxin","nanomachines","sacid")
			var/datum/reagents/R = new/datum/reagents(15)
			R.my_atom = src
			R.add_reagent(chosenchem , 15)
			var/datum/effect_system/smoke_spread/chem/smoke = new
			smoke.set_up(R, src, TRUE)
			playsound(loc, 'sound/effects/smoke.ogg', 50, TRUE, -3)
			smoke.start()
			qdel(R)
			ejectItem(TRUE)
			warn_admins(usr, "[chosenchem] smoke")
			investigate_log("Experimentor has released <font color='red'>[chosenchem]</font> smoke!", "experimentor")
		if(prob(EFFECT_PROB_LOW-badThingCoeff))
			visible_message("[src] malfunctions, spewing harmless gas.>")
			throwSmoke(loc)
		if(prob(EFFECT_PROB_MEDIUM-badThingCoeff))
			visible_message("<span class='warning'>[src] melts [exp_on], ionizing the air around it!</span>")
			empulse(loc, 4, 0) //change this to 4,6 once the EXPERI-Mentor is moved.
			investigate_log("Experimentor has generated an Electromagnetic Pulse.", "experimentor")
			ejectItem(TRUE)
	////////////////////////////////////////////////////////////////////////////////////////////////
	if(exp == SCANTYPE_HEAT)
		visible_message("[src] raises [exp_on]'s temperature.")
		if(prob(EFFECT_PROB_LOW) && criticalReaction)
			visible_message("<span class='warning'>[src]'s emergency coolant system gives off a small ding!</span>")
			playsound(loc, 'sound/machines/ding.ogg', 50, 1)
			var/obj/item/reagent_containers/drinks/coffee/C = new /obj/item/reagent_containers/drinks/coffee(get_turf(pick(oview(1,src))))
			chosenchem = pick("plasma","capsaicin","ethanol")
			C.reagents.remove_any(25)
			C.reagents.add_reagent(chosenchem , 50)
			C.name = "Cup of Suspicious Liquid"
			C.desc = "It has a large hazard symbol printed on the side in fading ink."
			investigate_log("Experimentor has made a cup of [chosenchem] coffee.", "experimentor")
		if(prob(EFFECT_PROB_VERYLOW-badThingCoeff))
			var/turf/start = get_turf(src)
			var/mob/M = locate(/mob/living) in view(src, 3)
			var/turf/MT = get_turf(M)
			if(MT)
				visible_message("<span class='danger'>[src] dangerously overheats, launching a flaming fuel orb!</span>")
				investigate_log("Experimentor has launched a <font color='red'>fireball</font> at [M]!", "experimentor")
				var/obj/item/projectile/magic/fireball/FB = new /obj/item/projectile/magic/fireball(start)
				FB.original = MT
				FB.current = start
				FB.yo = MT.y - start.y
				FB.xo = MT.x - start.x
				FB.fire()
		if(prob(EFFECT_PROB_LOW-badThingCoeff))
			visible_message("<span class='danger'>[src] malfunctions, melting [exp_on] and releasing a burst of flame!</span>")
			explosion(loc, -1, 0, 0, 0, 0, flame_range = 2)
			investigate_log("Experimentor started a fire.", "experimentor")
			ejectItem(TRUE)
		if(prob(EFFECT_PROB_MEDIUM-badThingCoeff))
			visible_message("<span class='warning'>[src] malfunctions, melting [exp_on] and leaking hot air!</span>")
			var/datum/milla_safe/experimentor_temperature/milla = new()
			milla.invoke_async(src, 100000, 1000)
			investigate_log("Experimentor has released hot air.", "experimentor")
			ejectItem(TRUE)
		if(prob(EFFECT_PROB_MEDIUM-badThingCoeff))
			visible_message("<span class='warning'>[src] malfunctions, activating its emergency coolant systems!</span>")
			throwSmoke(loc)
			for(var/mob/living/m in oview(1, src))
				m.apply_damage(5,BURN,pick("head","chest","groin"))
				investigate_log("Experimentor has dealt minor burn damage to [m]", "experimentor")
			ejectItem()
	////////////////////////////////////////////////////////////////////////////////////////////////
	if(exp == SCANTYPE_COLD)
		visible_message("[src] lowers [exp_on]'s temperature.")
		if(prob(EFFECT_PROB_LOW) && criticalReaction)
			visible_message("<span class='warning'>[src]'s emergency coolant system gives off a small ding!</span>")
			var/obj/item/reagent_containers/drinks/coffee/C = new /obj/item/reagent_containers/drinks/coffee(get_turf(pick(oview(1,src))))
			playsound(loc, 'sound/machines/ding.ogg', 50, 1) //Ding! Your death coffee is ready!
			chosenchem = pick("uranium","frostoil","ephedrine")
			C.reagents.remove_any(25)
			C.reagents.add_reagent(chosenchem , 50)
			C.name = "Cup of Suspicious Liquid"
			C.desc = "It has a large hazard symbol printed on the side in fading ink."
			investigate_log("Experimentor has made a cup of [chosenchem] coffee.", "experimentor")
		if(prob(EFFECT_PROB_VERYLOW-badThingCoeff))
			visible_message("<span class='danger'>[src] malfunctions, shattering [exp_on] and releasing a dangerous cloud of coolant!</span>")
			var/datum/reagents/R = new/datum/reagents(15)
			R.my_atom = src
			R.add_reagent("frostoil" , 15)
			investigate_log("Experimentor has released frostoil gas.", "experimentor")
			var/datum/effect_system/smoke_spread/chem/smoke = new
			smoke.set_up(R, src, TRUE)
			playsound(loc, 'sound/effects/smoke.ogg', 50, TRUE, -3)
			smoke.start()
			qdel(R)
			ejectItem(TRUE)
		if(prob(EFFECT_PROB_LOW-badThingCoeff))
			visible_message("<span class='warning'>[src] malfunctions, shattering [exp_on] and leaking cold air!</span>")
			var/datum/milla_safe/experimentor_temperature/milla = new()
			milla.invoke_async(src, -75000, 1000, TCMB)
			investigate_log("Experimentor has released cold air.", "experimentor")
			ejectItem(TRUE)
		if(prob(EFFECT_PROB_MEDIUM-badThingCoeff))
			visible_message("<span class='warning'>[src] malfunctions, releasing a flurry of chilly air as [exp_on] pops out!</span>")
			var/datum/effect_system/smoke_spread/smoke = new
			smoke.set_up(1, FALSE, loc)
			smoke.start()
			ejectItem()
	////////////////////////////////////////////////////////////////////////////////////////////////
	if(exp == SCANTYPE_OBLITERATE)
		visible_message("<span class='warning'>[exp_on] activates the crushing mechanism, [exp_on] is destroyed!</span>")
		if(prob(EFFECT_PROB_LOW) && criticalReaction)
			visible_message("<span class='warning'>[src]'s crushing mechanism slowly and smoothly descends, flattening [exp_on]!</span>")
			new /obj/item/stack/sheet/plasteel(get_turf(pick(oview(1,src))))
		if(linked_console.linked_lathe)
			var/datum/component/material_container/linked_materials = linked_console.linked_lathe.GetComponent(/datum/component/material_container)
			for(var/material in exp_on.materials)
				linked_materials.insert_amount( min((linked_materials.max_amount - linked_materials.total_amount), (exp_on.materials[material])), material)
		if(prob(EFFECT_PROB_VERYLOW-badThingCoeff))
			visible_message("<span class='danger'>[src]'s crusher goes way too many levels too high, crushing right through space-time!</span>")
			playsound(loc, 'sound/effects/supermatter.ogg', 50, TRUE, -3)
			investigate_log("Experimentor has triggered the 'throw things' reaction.", "experimentor")
			for(var/atom/movable/AM in oview(7,src))
				if(!AM.anchored)
					spawn(0)
						AM.throw_at(src,10,1)

		if(prob(EFFECT_PROB_LOW-badThingCoeff))
			visible_message("<span class='danger'>[src]'s crusher goes one level too high, crushing right into space-time!</span>")
			playsound(loc, 'sound/effects/supermatter.ogg', 50, TRUE, -3)
			investigate_log("Experimentor has triggered the 'minor throw things' reaction.", "experimentor")
			var/list/throwAt = list()
			for(var/atom/movable/AM in oview(7,src))
				if(!AM.anchored)
					throwAt.Add(AM)
			for(var/counter = 1, counter < length(throwAt), ++counter)
				var/atom/movable/cast = throwAt[counter]
				spawn(0)
					cast.throw_at(pick(throwAt),10,1)
		ejectItem(TRUE)
	////////////////////////////////////////////////////////////////////////////////////////////////
	if(exp == FAIL)
		var/a = pick("rumbles","shakes","vibrates","shudders")
		var/b = pick("crushes","spins","viscerates","smashes","insults")
		visible_message("<span class='warning'>[exp_on] [a], and [b], the experiment was a failure.</span>")

	if(exp == SCANTYPE_DISCOVER)
		visible_message("[src] scans [exp_on], revealing its true nature!")
		playsound(loc, 'sound/effects/supermatter.ogg', 50, 3, -1)
		var/obj/item/relic/R = loaded_item
		R.reveal()
		investigate_log("Experimentor has revealed a relic with effect ID <span class='danger'>[R.function_id]</span> effect.", "experimentor")
		ejectItem()

	//Global reactions

	if(prob(EFFECT_PROB_VERYLOW) && prob(13))
		visible_message("<span class='warning'>Experimentor draws the life essence of those nearby!</span>")
		for(var/mob/living/m in view(4,src))
			to_chat(m, "<span class='danger'>You feel your flesh being torn from you, mists of blood drifting to [src]!</span>")
			m.take_overall_damage(50)
			investigate_log("Experimentor has taken 50 brute a blood sacrifice from [m]", "experimentor")

	if(prob(EFFECT_PROB_VERYLOW-badThingCoeff) && prob(87))
		var/globalMalf = rand(1,87)
		if(globalMalf < 15)
			visible_message("<span class='warning'>[src]'s onboard detection system has malfunctioned!</span>")
			item_reactions["[exp_on.type]"] = pick(SCANTYPE_POKE,SCANTYPE_IRRADIATE,SCANTYPE_GAS,SCANTYPE_HEAT,SCANTYPE_COLD,SCANTYPE_OBLITERATE)
			ejectItem()
		if(globalMalf > 16 && globalMalf < 35)
			visible_message("<span class='warning'>[src] melts [exp_on], ian-izing the air around it!</span>")
			throwSmoke(loc)
			var/mob/tracked_ian = locate(/mob/living/simple_animal/pet/dog/corgi/Ian) in GLOB.mob_living_list
			if(tracked_ian)
				throwSmoke(tracked_ian.loc)
				tracked_ian.loc = loc
				if(tracked_ian.buckled)
					tracked_ian.buckled.unbuckle_mob(tracked_ian, TRUE)
				investigate_log("Experimentor has stolen Ian!", "experimentor") //...if anyone ever fixes it...
			else
				new /mob/living/simple_animal/pet/dog/corgi(loc)
				investigate_log("Experimentor has spawned a new corgi.", "experimentor")
			ejectItem(TRUE)
		if(globalMalf > 36 && globalMalf < 59)
			visible_message("<span class='warning'>[src] encounters a run-time error!</span>")
			throwSmoke(loc)
			var/mob/tracked_runtime = locate(/mob/living/simple_animal/pet/cat/Runtime) in GLOB.mob_living_list
			if(tracked_runtime)
				throwSmoke(tracked_runtime.loc)
				tracked_runtime.loc = loc
				if(tracked_runtime.buckled)
					tracked_runtime.buckled.unbuckle_mob(tracked_runtime, TRUE)
				investigate_log("Experimentor has stolen Runtime!", "experimentor")
			else
				new /mob/living/simple_animal/pet/cat(loc)
				investigate_log("Experimentor failed to steal runtime, and instead spawned a new cat.", "experimentor")
			ejectItem(TRUE)
		if(globalMalf > 60)
			visible_message("<span class='warning'>[src] begins to smoke and hiss, shaking violently!</span>")
			use_power(500000)
			investigate_log("Experimentor has drained power from its APC", "experimentor")

	spawn(resetTime)
		icon_state = "h_lathe"
		recentlyExperimented = 0

/datum/milla_safe/experimentor_temperature

/datum/milla_safe/experimentor_temperature/on_run(obj/machinery/r_n_d/experimentor/experimentor, delta, min_new_temp)
	var/turf/T = get_turf(experimentor)
	var/datum/gas_mixture/env = get_turf_air(T)

	var/transfer_moles = 0.25 * env.total_moles()
	var/datum/gas_mixture/removed = env.remove(transfer_moles)
	if(removed)
		var/heat_capacity = removed.heat_capacity()
		if(heat_capacity == 0 || heat_capacity == null)
			heat_capacity = 1
		removed.set_temperature(max(min_new_temp, (removed.temperature() * heat_capacity + delta) / heat_capacity))
	env.merge(removed)

/obj/machinery/r_n_d/experimentor/Topic(href, href_list)
	if(..())
		return
	if(!Adjacent(usr) && !issilicon(usr))
		return
	usr.set_machine(src)

	var/scantype = href_list["function"]
	var/obj/item/process = locate(href_list["item"]) in src

	if(href_list["close"])
		usr << browse(null, "window=experimentor")
		return
	else if(scantype == "search")
		var/obj/machinery/computer/rdconsole/D = locate(/obj/machinery/computer/rdconsole) in orange(range, src)
		if(D)
			linked_console = D
	else if(scantype == "eject")
		ejectItem()
	else if(scantype == "refresh")
		updateUsrDialog()
	else
		if(recentlyExperimented)
			to_chat(usr, "<span class='warning'>[src] has been used too recently!</span>")
			return
		else if(!loaded_item)
			updateUsrDialog() //Set the interface to unloaded mode
			to_chat(usr, "<span class='warning'>[src] is not currently loaded!</span>")
			return
		else if(!process || process != loaded_item) //Interface exploit protection (such as hrefs or swapping items with interface set to old item)
			updateUsrDialog() //Refresh interface to update interface hrefs
			to_chat(usr, "<span class='danger'>Interface failure detected in [src]. Please try again.</span>")
			return
		var/dotype
		if(text2num(scantype) == SCANTYPE_DISCOVER)
			dotype = SCANTYPE_DISCOVER
		else
			dotype = matchReaction(process,scantype)
		experiment(dotype,process)
		use_power(750)
		if(dotype != FAIL)
			if(process && process.origin_tech)
				var/list/temp_tech = ConvertReqString2List(process.origin_tech)
				var/datum/research/F = linked_console.get_files()
				if(!F)
					return
				for(var/T in temp_tech)
					F.UpdateTech(T, temp_tech[T])
	updateUsrDialog()
	return

//~~~~~~~~Admin logging proc, aka the Powergamer Alarm~~~~~~~~
/obj/machinery/r_n_d/experimentor/proc/warn_admins(mob/user, ReactionName)
	var/turf/T = get_turf(src)
	message_admins("Experimentor reaction: [ReactionName] generated by [key_name_admin(user)] at ([T.x], [T.y], [T.z] - <A href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>JMP</a>)",0,1)
	log_game("Experimentor reaction: [ReactionName] generated by [key_name(user)] in ([T.x], [T.y], [T.z])")

#undef SCANTYPE_POKE
#undef SCANTYPE_IRRADIATE
#undef SCANTYPE_GAS
#undef SCANTYPE_HEAT
#undef SCANTYPE_COLD
#undef SCANTYPE_OBLITERATE
#undef SCANTYPE_DISCOVER

#undef EFFECT_PROB_VERYLOW
#undef EFFECT_PROB_LOW
#undef EFFECT_PROB_MEDIUM
#undef EFFECT_PROB_HIGH
#undef EFFECT_PROB_VERYHIGH

#undef FAIL
