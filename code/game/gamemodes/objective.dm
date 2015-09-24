//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31
var/global/list/all_objectives = list()

var/list/potential_theft_objectives=subtypesof(/datum/theft_objective) \
	- /datum/theft_objective/steal \
	- /datum/theft_objective/special \
	- /datum/theft_objective/number \
	- /datum/theft_objective/number/special \
	- /datum/theft_objective/number/coins

datum/objective
	var/datum/mind/owner = null			//Who owns the objective.
	var/explanation_text = "Nothing"	//What that person is supposed to do.
	var/datum/mind/target = null		//If they are focused on a particular person.
	var/target_amount = 0				//If they are focused on a particular number. Steal objectives have their own counter.
	var/completed = 0					//currently only used for custom objectives.

	New(var/text)
		all_objectives |= src
		if(text)
			explanation_text = text

	Destroy()
		all_objectives -= src
		return ..()

	proc/check_completion()
		return completed

	proc/find_target()
		var/list/possible_targets = list()
		for(var/datum/mind/possible_target in ticker.minds)
			if(possible_target != owner && ishuman(possible_target.current) && (possible_target.current.stat != DEAD))
				possible_targets += possible_target
		if(possible_targets.len > 0)
			target = pick(possible_targets)

	proc/find_target_by_role(role, role_type=0)//Option sets either to check assigned role or special role. Default to assigned.
		var/list/possible_targets = list()
		for(var/datum/mind/possible_target in ticker.minds)
			if((possible_target != owner) && ishuman(possible_target.current) && ((role_type ? possible_target.special_role : possible_target.assigned_role) == role) && (possible_target.current.stat != DEAD) )
				possible_targets += possible_target
		if(possible_targets.len > 0)
			target = pick(possible_targets)

//Selects someone with a specific special role if role is != null. Or just anyone with a special role
	proc/find_target_with_special_role(role)
		var/list/possible_targets = list()
		for(var/datum/mind/possible_target in ticker.minds)
			if((possible_target != owner) && ishuman(possible_target.current) && (role && possible_target.special_role == role || !role && possible_target.special_role) && (possible_target.current.stat != DEAD) )
				possible_targets += possible_target
		if(possible_targets.len > 0)
			target = pick(possible_targets)


datum/objective/assassinate
	find_target()
		..()
		if(target && target.current)
			explanation_text = "Assassinate [target.current.real_name], the [target.assigned_role]."
		else
			explanation_text = "Free Objective"
		return target


	find_target_by_role(role, role_type=0)
		..(role, role_type)
		if(target && target.current)
			explanation_text = "Assassinate [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role]."
		else
			explanation_text = "Free Objective"
		return target


	check_completion()
		if(target && target.current)
			if(target.current.stat == DEAD || issilicon(target.current) || isbrain(target.current) || target.current.z > 6 || !target.current.ckey) //Borgs/brains/AIs count as dead for traitor objectives. --NeoFite
				return 1
			return 0
		return 1



datum/objective/mutiny
	find_target()
		..()
		if(target && target.current)
			explanation_text = "Assassinate [target.current.real_name], the [target.assigned_role]."
		else
			explanation_text = "Free Objective"
		return target


	find_target_by_role(role, role_type=0)
		..(role, role_type)
		if(target && target.current)
			explanation_text = "Assassinate  or exile [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role]."
		else
			explanation_text = "Free Objective"
		return target

	check_completion()
		if(target && target.current)
			if(target.current.stat == DEAD || !ishuman(target.current) || !target.current.ckey || !target.current.client)
				return 1
			var/turf/T = get_turf(target.current)
			if(T && !(T.z in config.station_levels))			//If they leave the station they count as dead for this
				return 2
			return 0
		return 1

datum/objective/mutiny/rp
	find_target()
		..()
		if(target && target.current)
			explanation_text = "Assassinate, capture or convert [target.current.real_name], the [target.assigned_role]."
		else
			explanation_text = "Free Objective"
		return target


	find_target_by_role(role, role_type=0)
		..(role, role_type)
		if(target && target.current)
			explanation_text = "Assassinate, capture or convert [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role]."
		else
			explanation_text = "Free Objective"
		return target

	// less violent rev objectives
	check_completion()
		var/rval = 1
		if(target && target.current)
			//assume that only carbon mobs can become rev heads for now
			if(target.current.stat == DEAD || target.current:handcuffed || !ishuman(target.current))
				return 1
			// Check if they're converted
			if(istype(ticker.mode, /datum/game_mode/revolution))
				if(target in ticker.mode:head_revolutionaries)
					return 1
			var/turf/T = get_turf(target.current)
			if(T && !(T.z in config.station_levels))			//If they leave the station they count as dead for this
				rval = 2
			return 0
		return rval

datum/objective/anti_revolution/execute
	find_target()
		..()
		if(target && target.current)
			explanation_text = "[target.current.real_name], the [target.assigned_role] has extracted confidential information above their clearance. Execute \him[target.current]."
		else
			explanation_text = "Free Objective"
		return target


	find_target_by_role(role, role_type=0)
		..(role, role_type)
		if(target && target.current)
			explanation_text = "[target.current.real_name], the [!role_type ? target.assigned_role : target.special_role] has extracted confidential information above their clearance. Execute \him[target.current]."
		else
			explanation_text = "Free Objective"
		return target

	check_completion()
		if(target && target.current)
			if(target.current.stat == DEAD || !ishuman(target.current))
				return 1
			return 0
		return 1

datum/objective/anti_revolution/brig
	var/already_completed = 0

	find_target()
		..()
		if(target && target.current)
			explanation_text = "Brig [target.current.real_name], the [target.assigned_role] for 20 minutes to set an example."
		else
			explanation_text = "Free Objective"
		return target


	find_target_by_role(role, role_type=0)
		..(role, role_type)
		if(target && target.current)
			explanation_text = "Brig [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role] for 20 minutes to set an example."
		else
			explanation_text = "Free Objective"
		return target

	check_completion()
		if(already_completed)
			return 1

		if(target && target.current)
			if(target.current.stat == DEAD)
				return 0
			if(target.is_brigged(10 * 60 * 10))
				already_completed = 1
				return 1
			return 0
		return 0

datum/objective/anti_revolution/demote
	find_target()
		..()
		if(target && target.current)
			explanation_text = "[target.current.real_name], the [target.assigned_role]  has been classified as harmful to Nanotrasen's goals. Demote \him[target.current] to assistant."
		else
			explanation_text = "Free Objective"
		return target

	find_target_by_role(role, role_type=0)
		..(role, role_type)
		if(target && target.current)
			explanation_text = "[target.current.real_name], the [!role_type ? target.assigned_role : target.special_role] has been classified as harmful to Nanotrasen's goals. Demote \him[target.current] to assistant."
		else
			explanation_text = "Free Objective"
		return target

	check_completion()
		if(target && target.current && istype(target,/mob/living/carbon/human))
			var/obj/item/weapon/card/id/I = target.current:wear_id
			if(istype(I, /obj/item/device/pda))
				var/obj/item/device/pda/P = I
				I = P.id

			if(!istype(I)) return 1

			if(I.assignment == "Civilian")
				return 1
			else
				return 0
		return 1

datum/objective/maroon
	find_target()
		..()
		if(target && target.current)
			explanation_text = "Prevent [target.current.real_name], the [target.assigned_role] from escaping alive."
		else
			explanation_text = "Free Objective"
		return target

	find_target_by_role(role, role_type=0)
		..(role, role_type)
		if(target && target.current)
			explanation_text = "Prevent [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role] from escaping alive."
		else
			explanation_text = "Free Objective"
		return target

	check_completion()
		if(target && target.current)
			if(target.current.stat == DEAD || issilicon(target.current) || isbrain(target.current) || target.current.z > 6 || !target.current.ckey) //Borgs/brains/AIs count as dead for traitor objectives. --NeoFite
				return 1
			if((target.current.z in config.admin_levels))
				return 0
		return 1

datum/objective/debrain//I want braaaainssss
	find_target()
		..()
		if(target && target.current)
			explanation_text = "Steal the brain of [target.current.real_name] the [target.assigned_role]."
		else
			explanation_text = "Free Objective"
		return target


	find_target_by_role(role, role_type=0)
		..(role, role_type)
		if(target && target.current)
			explanation_text = "Steal the brain of [target.current.real_name] the [!role_type ? target.assigned_role : target.special_role]."
		else
			explanation_text = "Free Objective"
		return target

	check_completion()
		if(!target)//If it's a free objective.
			return 1
		if( !owner.current || owner.current.stat==DEAD )//If you're otherwise dead.
			return 0
		if( !target.current || !isbrain(target.current) )
			return 0
		var/atom/A = target.current
		while(A.loc)			//check to see if the brainmob is on our person
			A = A.loc
			if(A == owner.current)
				return 1
		return 0


datum/objective/protect//The opposite of killing a dude.
	find_target()
		..()
		if(target && target.current)
			explanation_text = "Protect [target.current.real_name], the [target.assigned_role]."
		else
			explanation_text = "Free Objective"
		return target

	find_target_by_role(role, role_type=0)
		..(role, role_type)
		if(target && target.current)
			explanation_text = "Protect [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role]."
		else
			explanation_text = "Free Objective"
		return target

	find_target_with_special_role(role,role_type=0)
		..(role)
		if(target && target.current)
			explanation_text = "Protect [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role]."
		else
			explanation_text = "Free Objective"
		return target

	check_completion()
		if(!target)			//If it's a free objective.
			return 1
		if(target.current)
			if(target.current.stat == DEAD || issilicon(target.current) || isbrain(target.current))
				return 0
			return 1
		return 0


datum/objective/hijack
	explanation_text = "Hijack the shuttle to ensure no loyalist Nanotrasen crew escape alive."

	check_completion()
		if(!owner.current || owner.current.stat)
			return 0
		if(!emergency_shuttle.returned())
			return 0
		if(issilicon(owner.current))
			return 0
		var/area/shuttle = locate(/area/shuttle/escape/centcom)
		for(var/mob/living/player in player_list)
			if(istype(player, /mob/living/silicon) || istype(player, /mob/living/simple_animal) || player.mind.special_role && !player.mind.special_role == "Response Team")
				continue
			if (player.mind && (player.mind != owner))
				if(player.stat != DEAD)			//they're not dead!
					if(get_turf(player) in shuttle)
						return 0
		return 1

datum/objective/block
	explanation_text = "Do not allow any organic lifeforms to escape on the shuttle alive."

	check_completion()
		if(!istype(owner.current, /mob/living/silicon))
			return 0
		if(!emergency_shuttle.returned())
			return 0
		if(!owner.current)
			return 0
		var/area/shuttle = locate(/area/shuttle/escape/centcom)
		var/protected_mobs[] = list(/mob/living/silicon/ai, /mob/living/silicon/pai, /mob/living/silicon/robot)
		for(var/mob/living/player in player_list)
			if(player.type in protected_mobs)	continue
			if (player.mind)
				if (player.stat != DEAD)
					if (get_turf(player) in shuttle)
						return 0
		return 1

datum/objective/silence
	explanation_text = "Do not allow anyone to escape the station.  Only allow the shuttle to be called when everyone is dead and your story is the only one left."

	check_completion()
		if(!emergency_shuttle.returned())
			return 0

		for(var/mob/living/player in player_list)
			if(player == owner.current)
				continue
			if(player.mind)
				if(player.stat != DEAD)
					var/turf/T = get_turf(player)
					if(!T)	continue
					switch(T.loc.type)
						if(/area/shuttle/escape/centcom, /area/shuttle/escape_pod1/centcom, /area/shuttle/escape_pod2/centcom, /area/shuttle/escape_pod3/centcom, /area/shuttle/escape_pod5/centcom)
							return 0
		return 1


datum/objective/escape
	explanation_text = "Escape on the shuttle or an escape pod alive and free."
	var/escape_areas = list(/area/shuttle/escape/centcom,
		/area/shuttle/escape_pod1/centcom,
		/area/shuttle/escape_pod1/transit,
		/area/shuttle/escape_pod2/centcom,
		/area/shuttle/escape_pod2/transit,
		/area/shuttle/escape_pod3/centcom,
		/area/shuttle/escape_pod3/transit,
		/area/shuttle/escape_pod5/centcom,
		/area/shuttle/escape_pod5/transit,
		/area/centcom/evac)

	check_completion()
		if(issilicon(owner.current))
			return 0
		if(isbrain(owner.current))
			return 0
		if(!emergency_shuttle.returned())
			return 0
		if(!owner.current || owner.current.stat == DEAD)
			return 0
		if(owner.current.restrained())
			return 0
		var/turf/location = get_turf(owner.current.loc)
		if(!location)
			return 0

		var/area/check_area = get_area(location)
		if(check_area && check_area.type in escape_areas)
			return 1
		else
			return 0

datum/objective/escape/escape_with_identity
	var/target_real_name // Has to be stored because the target's real_name can change over the course of the round

	find_target()
		var/list/possible_targets = list() //Copypasta because NO_SCAN races, yay for snowflakes.
		for(var/datum/mind/possible_target in ticker.minds)
			if(possible_target != owner && ishuman(possible_target.current) && (possible_target.current.stat != DEAD))
				var/mob/living/carbon/human/H = possible_target.current
				if(!(H.species.flags & NO_SCAN))
					possible_targets += possible_target
		if(possible_targets.len > 0)
			target = pick(possible_targets)
		if(target && target.current)
			target_real_name = target.current.real_name
			explanation_text = "Escape on the shuttle or an escape pod with the identity of [target_real_name], the [target.assigned_role] while wearing their identification card."
		else
			explanation_text = "Free Objective"

	check_completion()
		if(!target_real_name)
			return 1
		if(!ishuman(owner.current))
			return 0
		var/mob/living/carbon/human/H = owner.current
		if(..())
			if(H.dna.real_name == target_real_name)
				if(H.get_id_name()== target_real_name)
					return 1
		return 0

datum/objective/die
	explanation_text = "Die a glorious death."

	check_completion()
		if(!owner.current || owner.current.stat == DEAD || isbrain(owner.current))
			return 1		//Brains no longer win survive objectives. --NEO
		if(issilicon(owner.current) && owner.current != owner.original)
			return 1
		return 0



datum/objective/survive
	explanation_text = "Stay alive until the end."

	check_completion()
		if(!owner.current || owner.current.stat == DEAD || isbrain(owner.current))
			return 0		//Brains no longer win survive objectives. --NEO
		if(issilicon(owner.current) && owner.current != owner.original)
			return 0
		return 1

// Similar to the anti-rev objective, but for traitors
datum/objective/brig
	var/already_completed = 0

	find_target()
		..()
		if(target && target.current)
			explanation_text = "Have [target.current.real_name], the [target.assigned_role] brigged for 10 minutes."
		else
			explanation_text = "Free Objective"
		return target


	find_target_by_role(role, role_type=0)
		..(role, role_type)
		if(target && target.current)
			explanation_text = "Have [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role] brigged for 10 minutes."
		else
			explanation_text = "Free Objective"
		return target

	check_completion()
		if(already_completed)
			return 1

		if(target && target.current)
			if(target.current.stat == DEAD)
				return 0
			// Make the actual required time a bit shorter than the official time
			if(target.is_brigged(10 * 60 * 5))
				already_completed = 1
				return 1
			return 0
		return 0

// Harm a crew member, making an example of them
datum/objective/harm
	var/already_completed = 0

	find_target()
		..()
		if(target && target.current)
			explanation_text = "Make an example of [target.current.real_name], the [target.assigned_role]. Break one of their bones, detach one of their limbs or disfigure their face. Make sure they're alive when you do it."
		else
			explanation_text = "Free Objective"
		return target


	find_target_by_role(role, role_type=0)
		..(role, role_type)
		if(target && target.current)
			explanation_text = "Make an example of [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role]. Break one of their bones, detach one of their limbs or disfigure their face. Make sure they're alive when you do it."
		else
			explanation_text = "Free Objective"
		return target

	check_completion()
		if(already_completed)
			return 1

		if(target && target.current && istype(target.current, /mob/living/carbon/human))
			if(target.current.stat == DEAD)
				return 0

			var/mob/living/carbon/human/H = target.current
			for(var/obj/item/organ/external/E in H.organs)
				if(E.status & ORGAN_BROKEN)
					return 1
			for(var/limb_tag in H.species.has_limbs) //todo check prefs for robotic limbs and amputations.
				var/list/organ_data = H.species.has_limbs[limb_tag]
				var/limb_type = organ_data["path"]
				var/found
				for(var/obj/item/organ/external/E in H.organs)
					if(limb_type == E.type)
						found = 1
						break
				if(!found)
					return 1

			var/obj/item/organ/external/head/head = H.get_organ("head")
			if(head.disfigured)
				return 1
		return 0


datum/objective/nuclear
	explanation_text = "Destroy the station with a nuclear device."



datum/objective/steal
	var/datum/theft_objective/steal_target

	find_target(var/special_only=0)
		var/loop=50
		while(!steal_target && loop > 0)
			loop--
			var/thefttype = pick(potential_theft_objectives)
			var/datum/theft_objective/O = new thefttype
			if(owner.assigned_role in O.protected_jobs)
				continue
			if(special_only)
				if(!(O.flags & 1)) // THEFT_FLAG_SPECIAL
					continue
			else
				if(O.flags & 1) // THEFT_FLAG_SPECIAL
					continue
			if(O.flags & 2)
				continue
			steal_target=O
			explanation_text = "Steal [O]."
			return
		explanation_text = "Free Objective."


	proc/select_target()
		var/list/possible_items_all = potential_theft_objectives+"custom"
		var/new_target = input("Select target:", "Objective target", null) as null|anything in possible_items_all
		if (!new_target) return
		if (new_target == "custom")
			var/datum/theft_objective/O=new
			O.typepath = input("Select type:","Type") as null|anything in typesof(/obj/item)
			if (!O.typepath) return
			var/tmp_obj = new O.typepath
			var/custom_name = tmp_obj:name
			qdel(tmp_obj)
			O.name = sanitize(copytext(input("Enter target name:", "Objective target", custom_name) as text|null,1,MAX_NAME_LEN))
			if (!O.name) return
			steal_target = O
			explanation_text = "Steal [O.name]."
		else
			steal_target = new new_target
			explanation_text = "Steal [steal_target.name]."
		return steal_target

	check_completion()
		if(!steal_target) return 1 // Free Objective
		return steal_target.check_completion(owner)

datum/objective/steal/exchange

	proc/set_faction(var/faction,var/otheragent)
		target = otheragent
		var/datum/theft_objective/unique/targetinfo
		if(faction == "red")
			targetinfo = new /datum/theft_objective/unique/docs_blue
		else if(faction == "blue")
			targetinfo = new /datum/theft_objective/unique/docs_red
		explanation_text = "Acquire [targetinfo.name] held by [target.current.real_name], the [target.assigned_role] and syndicate agent"
		steal_target = targetinfo

datum/objective/steal/exchange/backstab

	set_faction(var/faction)
		var/datum/theft_objective/unique/targetinfo
		if(faction == "red")
			targetinfo = new /datum/theft_objective/unique/docs_red
		else if(faction == "blue")
			targetinfo = new /datum/theft_objective/unique/docs_blue
		explanation_text = "Do not give up or lose [targetinfo.name]."
		steal_target = targetinfo

datum/objective/download
	proc/gen_amount_goal()
		target_amount = rand(10,20)
		explanation_text = "Download [target_amount] research levels."
		return target_amount


	check_completion()
		return 0



datum/objective/capture
	proc/gen_amount_goal()
		target_amount = rand(5,10)
		explanation_text = "Accumulate [target_amount] capture points."
		return target_amount


	check_completion()//Basically runs through all the mobs in the area to determine how much they are worth.
		return 0




datum/objective/absorb
	proc/gen_amount_goal(var/lowbound = 4, var/highbound = 6)
		target_amount = rand (lowbound,highbound)
		if (ticker)
			var/n_p = 1 //autowin
			if (ticker.current_state == GAME_STATE_SETTING_UP)
				for(var/mob/new_player/P in player_list)
					if(P.client && P.ready && P.mind != owner)
						if(P.client.prefs && (P.client.prefs.species == "Vox" || P.client.prefs.species == "Slime People" || P.client.prefs.species == "Machine")) // Special check for species that can't be absorbed. No better solution.
							continue
						n_p ++
			else if (ticker.current_state == GAME_STATE_PLAYING)
				for(var/mob/living/carbon/human/P in player_list)
					if(P.species.flags & NO_SCAN)
						continue
					if(P.client && !(P.mind in ticker.mode.changelings) && P.mind!=owner)
						n_p ++
			target_amount = min(target_amount, n_p)

		explanation_text = "Absorb [target_amount] compatible genomes."
		return target_amount

	check_completion()
		if(owner && owner.changeling && owner.changeling.absorbed_dna && (owner.changeling.absorbedcount >= target_amount))
			return 1
		else
			return 0

datum/objective/destroy
	var/target_real_name
	find_target()
		var/list/possible_targets = active_ais(1)
		var/mob/living/silicon/ai/target_ai = pick(possible_targets)
		target = target_ai.mind
		if(target && target.current)
			target_real_name = target.current.real_name
			explanation_text = "Destroy [target_real_name], the AI."
		else
			explanation_text = "Free Objective"
		return target

	check_completion()
		if(target && target.current)
			if(target.current.stat == DEAD || target.current.z > 6 || !target.current.ckey)
				return 1
			return 0
		return 1

/* Isn't suited for global objectives
/*---------CULTIST----------*/

		eldergod
			explanation_text = "Summon Nar-Sie via the use of an appropriate rune. It will only work if nine cultists stand on and around it."

			check_completion()
				if(!eldergod) //global var, defined in rune4.dm
					return 1
				return 0

		survivecult
			var/num_cult
			var/cult_needed = 4 + round((num_players_started() / 10))

			explanation_text = "Our knowledge must live on. Make sure at least [cult_needed] acolytes escape on the shuttle to spread their work on an another station."

			check_completion()
				if(!emergency_shuttle.returned())
					return 0

				var/cultists_escaped = 0

				var/area/shuttle/escape/centcom/C = /area/shuttle/escape/centcom
				for(var/turf/T in	get_area_turfs(C.type))
					for(var/mob/living/carbon/H in T)
						if(iscultist(H))
							cultists_escaped++

				if(cultists_escaped >= cult_needed)
					return 1

				return 0

		sacrifice //stolen from traitor target objective

			proc/find_target() //I don't know how to make it work with the rune otherwise, so I'll do it via a global var, sacrifice_target, defined in rune15.dm
				var/datum/game_mode/cult/C = ticker.mode
				var/list/possible_targets = C.get_unconvertables()

				if(!possible_targets.len)
					for(var/mob/living/carbon/human/player in player_list)
						if(player.mind && !(player.mind in cult))
							possible_targets += player.mind

				if(possible_targets.len > 0)
					sacrifice_target = pick(possible_targets)

				if(sacrifice_target && sacrifice_target.current)
					explanation_text = "Sacrifice [sacrifice_target.current.real_name], the [sacrifice_target.assigned_role]. You will need the sacrifice rune (hell join blood) and three acolytes to do so."
				else
					explanation_text = "Free Objective"

				return sacrifice_target

			check_completion() //again, calling on a global list defined in rune15.dm
				if(sacrifice_target in sacrificed)
					return 1
				else
					return 0

/*-------ENDOF CULTIST------*/
*/

datum/objective/blood
	proc/gen_amount_goal(low = 150, high = 400)
		target_amount = rand(low,high)
		target_amount = round(round(target_amount/5)*5)
		explanation_text = "Accumulate atleast [target_amount] units of blood in total."
		return target_amount

	check_completion()
		if(owner && owner.vampire && owner.vampire.bloodtotal && owner.vampire.bloodtotal >= target_amount)
			return 1
		else
			return 0

// /vg/; Vox Inviolate for humans :V
datum/objective/minimize_casualties
	explanation_text = "Minimise casualties."
	check_completion()
		if(owner.kills.len>5) return 0
		return 1

//Vox heist objectives.

datum/objective/heist
	proc/choose_target()
		return

datum/objective/heist/kidnap
	choose_target()
		var/list/roles = list("Chief Engineer","Research Director","Roboticist","Chemist","Station Engineer")
		var/list/possible_targets = list()
		var/list/priority_targets = list()

		for(var/datum/mind/possible_target in ticker.minds)
			if(possible_target != owner && ishuman(possible_target.current) && (possible_target.current.stat != DEAD) && (possible_target.assigned_role != "MODE"))
				possible_targets += possible_target
				for(var/role in roles)
					if(possible_target.assigned_role == role)
						priority_targets += possible_target
						continue

		if(priority_targets.len > 0)
			target = pick(priority_targets)
		else if(possible_targets.len > 0)
			target = pick(possible_targets)

		if(target && target.current)
			explanation_text = "The Shoal has a need for [target.current.real_name], the [target.assigned_role]. Take them alive."
		else
			explanation_text = "Free Objective"
		return target

	check_completion()
		if(target && target.current)
			if (target.current.stat == DEAD)
				return 0 // They're dead. Fail.
			//if (!target.current.restrained())
			//	return 0 // They're loose. Close but no cigar.

			var/area/shuttle/vox/station/A = locate()
			for(var/mob/living/carbon/human/M in A)
				if(target.current == M)
					return 1 //They're restrained on the shuttle. Success.
		else
			return 0

datum/objective/heist/loot

	choose_target()
		var/loot = "an object"
		switch(rand(1,8))
			if(1)
				target = /obj/structure/particle_accelerator
				target_amount = 6
				loot = "a complete particle accelerator"
			if(2)
				target = /obj/machinery/the_singularitygen
				target_amount = 1
				loot = "a gravitational singularity generator"
			if(3)
				target = /obj/machinery/power/emitter
				target_amount = 4
				loot = "four emitters"
			if(4)
				target = /obj/machinery/nuclearbomb
				target_amount = 1
				loot = "a nuclear bomb"
			if(5)
				target = /obj/item/weapon/gun
				target_amount = 6
				loot = "six guns"
			if(6)
				target = /obj/item/weapon/gun/energy
				target_amount = 4
				loot = "four energy guns"
			if(7)
				target = /obj/item/weapon/gun/energy/laser
				target_amount = 2
				loot = "two laser guns"
			if(8)
				target = /obj/item/weapon/gun/energy/ionrifle
				target_amount = 1
				loot = "an ion gun"

		explanation_text = "We are lacking in hardware. Steal or trade [loot]."

	check_completion()

		var/total_amount = 0

		for(var/obj/O in locate(/area/shuttle/vox/station))
			if(istype(O,target)) total_amount++
			for(var/obj/I in O.contents)
				if(istype(I,target)) total_amount++
			if(total_amount >= target_amount) return 1

		var/datum/game_mode/heist/H = ticker.mode
		for(var/datum/mind/raider in H.raiders)
			if(raider.current)
				for(var/obj/O in raider.current.get_contents())
					if(istype(O,target)) total_amount++
					if(total_amount >= target_amount) return 1

		return 0

datum/objective/heist/salvage

	choose_target()
		switch(rand(1,8))
			if(1)
				target = "metal"
				target_amount = 300
			if(2)
				target = "glass"
				target_amount = 200
			if(3)
				target = "plasteel"
				target_amount = 100
			if(4)
				target = "solid plasma"
				target_amount = 100
			if(5)
				target = "silver"
				target_amount = 50
			if(6)
				target = "gold"
				target_amount = 20
			if(7)
				target = "uranium"
				target_amount = 20
			if(8)
				target = "diamond"
				target_amount = 20

		explanation_text = "Ransack or trade with the station and escape with [target_amount] [target]."

	check_completion()

		var/total_amount = 0

		for(var/obj/item/O in locate(/area/shuttle/vox/station))

			var/obj/item/stack/sheet/S
			if(istype(O,/obj/item/stack/sheet))
				if(O.name == target)
					S = O
					total_amount += S.get_amount()
			for(var/obj/I in O.contents)
				if(istype(I,/obj/item/stack/sheet))
					if(I.name == target)
						S = I
						total_amount += S.get_amount()

		var/datum/game_mode/heist/H = ticker.mode
		for(var/datum/mind/raider in H.raiders)
			if(raider.current)
				for(var/obj/item/O in raider.current.get_contents())
					if(istype(O,/obj/item/stack/sheet))
						if(O.name == target)
							var/obj/item/stack/sheet/S = O
							total_amount += S.get_amount()

		if(total_amount >= target_amount) return 1
		return 0


datum/objective/heist/inviolate_crew
	explanation_text = "Do not leave any Vox behind, alive or dead."

	check_completion()
		var/datum/game_mode/heist/H = ticker.mode
		if(H.is_raider_crew_safe()) return 1
		return 0

#define MAX_VOX_KILLS 10 //Number of kills during the round before the Inviolate is broken.
						 //Would be nice to use vox-specific kills but is currently not feasible.
var/global/vox_kills = 0 //Used to check the Inviolate.

datum/objective/heist/inviolate_death
	explanation_text = "Follow the Inviolate. Minimise death and loss of resources."
	check_completion()
		if(vox_kills > MAX_VOX_KILLS) return 0
		return 1