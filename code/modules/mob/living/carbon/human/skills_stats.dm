
/mob/living/carbon
	var/datum/skills/my_skills = null
	var/global/mentalfatigue = 1

	proc
		init_skills()
			var/datum/skills/newSkills = new
			newSkills.host = src
			newSkills.rand_stats()
			my_skills = newSkills

/datum/skills
	var/mob/living/carbon/host = null
	var/list/skills_holder[SKILL_SIZE]
	var/list/prepare_learn = list()
	var/max_value = 10 //Maxium that can be learn through regular actions.

/*
skills are kept in a global list because they don't need to change runtime
and we don't want every human to have 37 copies of the same thing.
*/
var/static/list/global_skills

/datum/skills/New()
	if(!global_skills)
		global_skills = list()
		for(var/skill_type in subtypesof(/datum/skill))
			var/datum/skill/skill = new skill_type
			global_skills += skill
	for(var/datum/skill/skill in global_skills)
		skills_holder[skill.id] = list("value" = 0, "data"= skill)


/datum/skills/proc/ADD_SKILL(var/stat,var/n)
	var/S = get_skill_value(stat,src)
	S += n
	if(!S)
		return 0
	get_skill_value(stat,src) = S
	return S

/datum/skills/proc/REDUCE_SKILL(var/stat,var/n)
	var/S = get_skill_value(stat,src)
	S -= n
	if(!S)
		return 0
	get_skill_value(stat,src) = S
	return S

/datum/skills/proc/CHANGE_SKILL(var/stat,var/n)
	get_skill_value(stat,src) = n
	return n

/datum/skills/proc/GET_SKILL(var/stat)
	var/S = get_skill_value(stat,src)
	if(!S)
		return 0
	return S

/datum/skills/proc/GET_SKILL_NAME(var/stat)
	var/S = get_skill_data(stat,src)
	if(!S)
		return 0
	return S:name

/datum/skills

	proc
		rand_stats()
			CHANGE_SKILL(SKILL_MELEE,rand(0,0))
			CHANGE_SKILL(SKILL_RANGE,rand(0,0))
			CHANGE_SKILL(SKILL_FARM,rand(0,0))
			CHANGE_SKILL(SKILL_COOK,rand(0,0))
			CHANGE_SKILL(SKILL_ENGINE,rand(0,0))
			CHANGE_SKILL(SKILL_SURG,rand(0,0))
			CHANGE_SKILL(SKILL_MEDIC,rand(0,0))
			CHANGE_SKILL(SKILL_CLEAN,rand(0,0))
			CHANGE_SKILL(SKILL_MASON,rand(0,0))
			CHANGE_SKILL(SKILL_SMITH,rand(0,0))
			CHANGE_SKILL(SKILL_CLIMB,rand(0,0))
			CHANGE_SKILL(SKILL_SWIM, rand(0,0))
			CHANGE_SKILL(SKILL_PARTY, rand(0,9))
			CHANGE_SKILL(SKILL_SURVIV, rand(2,4))
			CHANGE_SKILL(SKILL_CRAFT, rand(2,4))
			CHANGE_SKILL(SKILL_UNARM, rand(0,1))
			CHANGE_SKILL(SKILL_TAN, rand(2,6))

		job_stats(var/job)
			if(job)
				switch(job)
					if("Baron")
						CHANGE_SKILL(SKILL_SWORD,rand(0,2))
						CHANGE_SKILL(SKILL_MELEE,rand(9,9))
						CHANGE_SKILL(SKILL_RANGE, rand(8,8))
						CHANGE_SKILL(SKILL_FARM,rand(0,0))
						CHANGE_SKILL(SKILL_COOK,rand(5,5))
						CHANGE_SKILL(SKILL_ENGINE,rand(0,0))
						CHANGE_SKILL(SKILL_SURG,rand(0,0))
						CHANGE_SKILL(SKILL_MEDIC,rand(0,0))
						CHANGE_SKILL(SKILL_CLEAN,rand(3,3))
						CHANGE_SKILL(SKILL_CLIMB,rand(8,8))
						CHANGE_SKILL(SKILL_PARTY,rand(6,6))
						CHANGE_SKILL(SKILL_SWIM,rand(7,7))
						CHANGE_SKILL(SKILL_MUSIC, rand(0,0))
						CHANGE_SKILL(SKILL_OBSERV, rand(8,8))
					if("Heir")
						CHANGE_SKILL(SKILL_SWORD,rand(0,1))
						CHANGE_SKILL(SKILL_MELEE,rand(8,8))
						CHANGE_SKILL(SKILL_RANGE, rand(6,6))
						CHANGE_SKILL(SKILL_FARM,rand(0,0))
						CHANGE_SKILL(SKILL_COOK,rand(0,0))
						CHANGE_SKILL(SKILL_ENGINE,rand(0,0))
						CHANGE_SKILL(SKILL_SURG,rand(0,0))
						CHANGE_SKILL(SKILL_MEDIC,rand(0,0))
						CHANGE_SKILL(SKILL_CLEAN,rand(0,0))
						CHANGE_SKILL(SKILL_CLIMB,rand(8,8))
						CHANGE_SKILL(SKILL_PARTY,rand(11,11))
						CHANGE_SKILL(SKILL_SWIM,rand(7,7))
						CHANGE_SKILL(SKILL_MUSIC, rand(0,1))
						CHANGE_SKILL(SKILL_OBSERV, rand(8,8))
						CHANGE_SKILL(SKILL_UNARM, rand(0,1))
					if("Meister")
						CHANGE_SKILL(SKILL_MELEE,rand(6,6))
						CHANGE_SKILL(SKILL_RANGE, rand(8,8))
						CHANGE_SKILL(SKILL_FARM,rand(0,0))
						CHANGE_SKILL(SKILL_COOK,rand(0,0))
						CHANGE_SKILL(SKILL_ENGINE,rand(0,0))
						CHANGE_SKILL(SKILL_SURG,rand(0,0))
						CHANGE_SKILL(SKILL_MEDIC,rand(0,0))
						CHANGE_SKILL(SKILL_CLEAN,rand(0,0))
						CHANGE_SKILL(SKILL_CLIMB,rand(6,6))
						CHANGE_SKILL(SKILL_PARTY,rand(0,0))
						CHANGE_SKILL(SKILL_SWIM,rand(5,5))
						CHANGE_SKILL(SKILL_MUSIC, rand(0,0))
						CHANGE_SKILL(SKILL_OBSERV, rand(5,5))
					if("Hand")
						CHANGE_SKILL(SKILL_SWORD,rand(0,2))
						CHANGE_SKILL(SKILL_MELEE,rand(9,9))
						CHANGE_SKILL(SKILL_RANGE, rand(8,8))
						CHANGE_SKILL(SKILL_FARM,rand(0,0))
						CHANGE_SKILL(SKILL_COOK,rand(5,5))
						CHANGE_SKILL(SKILL_ENGINE,rand(0,0))
						CHANGE_SKILL(SKILL_SURG,rand(0,0))
						CHANGE_SKILL(SKILL_MEDIC,rand(0,0))
						CHANGE_SKILL(SKILL_CLEAN,rand(3,3))
						CHANGE_SKILL(SKILL_CLIMB,rand(8,8))
						CHANGE_SKILL(SKILL_PARTY,rand(6,6))
						CHANGE_SKILL(SKILL_SWIM,rand(7,7))
						CHANGE_SKILL(SKILL_MUSIC, rand(0,0))
						CHANGE_SKILL(SKILL_OBSERV, rand(8,8))
					if("Guest")
						CHANGE_SKILL(SKILL_MELEE,rand(8,8))
						CHANGE_SKILL(SKILL_RANGE, rand(7,7))
						CHANGE_SKILL(SKILL_FARM,rand(0,0))
						CHANGE_SKILL(SKILL_COOK,rand(0,0))
						CHANGE_SKILL(SKILL_ENGINE,rand(0,0))
						CHANGE_SKILL(SKILL_SURG,rand(0,1))
						CHANGE_SKILL(SKILL_MEDIC,rand(0,0))
						CHANGE_SKILL(SKILL_CLEAN,rand(5,5))
						CHANGE_SKILL(SKILL_CLIMB,rand(8,8))
						CHANGE_SKILL(SKILL_PARTY,rand(10,11))
						CHANGE_SKILL(SKILL_SWIM,rand(6,7))
						CHANGE_SKILL(SKILL_MUSIC, rand(0,0))
						CHANGE_SKILL(SKILL_OBSERV, rand(8,9))
					if("Innkeeper")
						CHANGE_SKILL(SKILL_MELEE,rand(9,9))
						CHANGE_SKILL(SKILL_RANGE, 10)
						CHANGE_SKILL(SKILL_FARM,rand(9,9))
						CHANGE_SKILL(SKILL_COOK,rand(14,16))
						CHANGE_SKILL(SKILL_ENGINE,rand(0,0))
						CHANGE_SKILL(SKILL_SURG,rand(0,2))
						CHANGE_SKILL(SKILL_MEDIC,rand(0,0))
						CHANGE_SKILL(SKILL_CLEAN,rand(8,3))
						CHANGE_SKILL(SKILL_CLIMB,rand(8,8))
						CHANGE_SKILL(SKILL_OBSERV, rand(0,2))
					if("Innkeeper Wife")
						CHANGE_SKILL(SKILL_MELEE,rand(6,6))
						CHANGE_SKILL(SKILL_RANGE, rand(9,9))
						CHANGE_SKILL(SKILL_FARM,rand(9,9))
						CHANGE_SKILL(SKILL_COOK,rand(14,16))
						CHANGE_SKILL(SKILL_ENGINE,rand(0,0))
						CHANGE_SKILL(SKILL_SURG,rand(7,8))
						CHANGE_SKILL(SKILL_MEDIC,rand(0,0))
						CHANGE_SKILL(SKILL_CLEAN, 10)
						CHANGE_SKILL(SKILL_CLIMB,rand(8,8))
						CHANGE_SKILL(SKILL_OBSERV, rand(0,0))
					if("Prophet")
						CHANGE_SKILL(SKILL_MELEE,rand(12,12))
						CHANGE_SKILL(SKILL_RANGE,rand(0,0))
						CHANGE_SKILL(SKILL_FARM,rand(0,0))
						CHANGE_SKILL(SKILL_COOK,rand(10,10))
						CHANGE_SKILL(SKILL_ENGINE,rand(0,0))
						CHANGE_SKILL(SKILL_SURG,rand(8,8))
						CHANGE_SKILL(SKILL_MEDIC,rand(8,8))
						CHANGE_SKILL(SKILL_CLEAN,rand(8,8))
						CHANGE_SKILL(SKILL_CLIMB,rand(10,10))
						CHANGE_SKILL(SKILL_SWIM,rand(8,8))
						CHANGE_SKILL(SKILL_OBSERV, rand(0,0))
					if("Butler")
						CHANGE_SKILL(SKILL_MELEE,rand(6,6))
						CHANGE_SKILL(SKILL_RANGE,rand(6,6))
						CHANGE_SKILL(SKILL_FARM,rand(11,11))
						CHANGE_SKILL(SKILL_COOK,rand(13,13))
						CHANGE_SKILL(SKILL_ENGINE,rand(0,0))
						CHANGE_SKILL(SKILL_SURG,rand(9,9))
						CHANGE_SKILL(SKILL_CLIMB,rand(8,8))
						CHANGE_SKILL(SKILL_MEDIC,rand(8,8))
						CHANGE_SKILL(SKILL_CLEAN,rand(11,11))
						CHANGE_SKILL(SKILL_OBSERV, rand(0,0))
					if("Sitzfrau")
						CHANGE_SKILL(SKILL_MELEE,rand(5,5))
						CHANGE_SKILL(SKILL_RANGE,rand(6,6))
						CHANGE_SKILL(SKILL_FARM,rand(11,11))
						CHANGE_SKILL(SKILL_COOK,rand(13,13))
						CHANGE_SKILL(SKILL_ENGINE,rand(0,0))
						CHANGE_SKILL(SKILL_SURG,rand(9,9))
						CHANGE_SKILL(SKILL_CLIMB,rand(8,8))
						CHANGE_SKILL(SKILL_MEDIC,rand(8,8))
						CHANGE_SKILL(SKILL_CLEAN,rand(13,14))
						CHANGE_SKILL(SKILL_MUSIC, rand(0,0))
						CHANGE_SKILL(SKILL_OBSERV, rand(8,8))
					if("Mortus")
						CHANGE_SKILL(SKILL_MELEE,rand(11,11))
						CHANGE_SKILL(SKILL_UNARM,rand(1,2))
						CHANGE_SKILL(SKILL_RANGE,rand(6,6))
						CHANGE_SKILL(SKILL_FARM,rand(0,0))
						CHANGE_SKILL(SKILL_COOK,rand(0,0))
						CHANGE_SKILL(SKILL_ENGINE,rand(0,0))
						CHANGE_SKILL(SKILL_SURG,rand(8,8))
						CHANGE_SKILL(SKILL_MEDIC,rand(0,0))
						CHANGE_SKILL(SKILL_CLEAN,rand(0,0))
						CHANGE_SKILL(SKILL_CLIMB,rand(12,12))
						CHANGE_SKILL(SKILL_SWIM,rand(6,8))
						CHANGE_SKILL(SKILL_OBSERV, rand(10,10))
					if("Pusher")
						CHANGE_SKILL(SKILL_MELEE,rand(11,11))
						CHANGE_SKILL(SKILL_RANGE,rand(9,9))
						CHANGE_SKILL(SKILL_UNARM, rand(0,2))
						CHANGE_SKILL(SKILL_FARM,rand(0,0))
						CHANGE_SKILL(SKILL_COOK,rand(0,0))
						CHANGE_SKILL(SKILL_ENGINE,rand(0,0))
						CHANGE_SKILL(SKILL_CLIMB,rand(10,10))
						CHANGE_SKILL(SKILL_SURG,rand(8,8))
						CHANGE_SKILL(SKILL_MEDIC,rand(9,9))
						CHANGE_SKILL(SKILL_CLEAN,rand(0,0))
						CHANGE_SKILL(SKILL_PARTY, rand(13,14))
						CHANGE_SKILL(SKILL_OBSERV, rand(9,9))
					if("Soiler")
						CHANGE_SKILL(SKILL_MELEE,rand(8,8))
						CHANGE_SKILL(SKILL_RIDE,rand(12,13))
						CHANGE_SKILL(SKILL_RANGE,rand(6,6))
						CHANGE_SKILL(SKILL_UNARM,rand(0,2))
						CHANGE_SKILL(SKILL_FARM,rand(14,15))
						CHANGE_SKILL(SKILL_COOK,rand(9,9))
						CHANGE_SKILL(SKILL_ENGINE,rand(0,0))
						CHANGE_SKILL(SKILL_SURG,rand(0,0))
						CHANGE_SKILL(SKILL_MEDIC,rand(0,0))
						CHANGE_SKILL(SKILL_CLEAN,rand(0,0))
						CHANGE_SKILL(SKILL_CLIMB,rand(8,8))
						CHANGE_SKILL(SKILL_SWIM,rand(9,9))
						CHANGE_SKILL(SKILL_OBSERV, rand(8,9))
						CHANGE_SKILL(SKILL_TAN, rand(11,13))
					if("Bookkeeper")
						CHANGE_SKILL(SKILL_MELEE,rand(9,9))
						CHANGE_SKILL(SKILL_RANGE,rand(12,12))
						CHANGE_SKILL(SKILL_FARM,rand(0,0))
						CHANGE_SKILL(SKILL_COOK,rand(0,0))
						CHANGE_SKILL(SKILL_ENGINE,rand(0,0))
						CHANGE_SKILL(SKILL_SURG,rand(8,8))
						CHANGE_SKILL(SKILL_MEDIC,rand(8,8))
						CHANGE_SKILL(SKILL_CLEAN,rand(7,7))
						CHANGE_SKILL(SKILL_CLIMB,rand(9,9))
						CHANGE_SKILL(SKILL_OBSERV, rand(10,10))
						CHANGE_SKILL(SKILL_BOAT, rand(0,0))
					if("Maid")
						CHANGE_SKILL(SKILL_MELEE,rand(5,5))
						CHANGE_SKILL(SKILL_RANGE,rand(5,5))
						CHANGE_SKILL(SKILL_FARM,rand(9,10))
						CHANGE_SKILL(SKILL_COOK,rand(10,11))
						CHANGE_SKILL(SKILL_ENGINE,rand(0,0))
						CHANGE_SKILL(SKILL_SURG,rand(6,7))
						CHANGE_SKILL(SKILL_MEDIC,rand(6,7))
						CHANGE_SKILL(SKILL_CLEAN, 12)
						CHANGE_SKILL(SKILL_CLIMB,rand(8,8))
						CHANGE_SKILL(SKILL_STEAL,rand(0,0))
						CHANGE_SKILL(SKILL_SWIM,rand(0,0))
						CHANGE_SKILL(SKILL_OBSERV, rand(8,9))
					if("Amuser")
						CHANGE_SKILL(SKILL_MELEE,rand(5,5))
						CHANGE_SKILL(SKILL_RANGE,rand(5,5))
						CHANGE_SKILL(SKILL_FARM,rand(0,0))
						CHANGE_SKILL(SKILL_COOK,rand(0,0))
						CHANGE_SKILL(SKILL_ENGINE,rand(0,0))
						CHANGE_SKILL(SKILL_SURG,rand(0,0))
						CHANGE_SKILL(SKILL_MEDIC,rand(0,0))
						CHANGE_SKILL(SKILL_RIDE,rand(13,17))
						CHANGE_SKILL(SKILL_PARTY,rand(10,13))
						CHANGE_SKILL(SKILL_CLEAN,rand(0,0))
						CHANGE_SKILL(SKILL_CLIMB,rand(8,8))
						CHANGE_SKILL(SKILL_STEAL,rand(7,11))
						CHANGE_SKILL(SKILL_SWIM,rand(5,5))
						CHANGE_SKILL(SKILL_MUSIC, rand(0,0))
						CHANGE_SKILL(SKILL_KNIFE,rand(0,2))
						CHANGE_SKILL(SKILL_OBSERV, rand(8,9))
					if("Successor")
						CHANGE_SKILL(SKILL_MELEE,rand(5,5))
						CHANGE_SKILL(SKILL_RANGE,rand(8,8))
						CHANGE_SKILL(SKILL_FARM,rand(0,0))
						CHANGE_SKILL(SKILL_COOK,rand(0,0))
						CHANGE_SKILL(SKILL_ENGINE,rand(0,0))
						CHANGE_SKILL(SKILL_SURG,rand(0,0))
						CHANGE_SKILL(SKILL_MEDIC,rand(0,0))
						CHANGE_SKILL(SKILL_CLEAN,rand(0,0))
						CHANGE_SKILL(SKILL_CLIMB,rand(8,8))
						CHANGE_SKILL(SKILL_STEAL,rand(0,0))
						CHANGE_SKILL(SKILL_SWIM,rand(9,10))
						CHANGE_SKILL(SKILL_MUSIC, rand(12,12))
						CHANGE_SKILL(SKILL_KNIFE,rand(0,3))
						CHANGE_SKILL(SKILL_OBSERV, rand(8,9))
					if("Baroness")
						CHANGE_SKILL(SKILL_MELEE,rand(5,5))
						CHANGE_SKILL(SKILL_RANGE,rand(8,9))
						CHANGE_SKILL(SKILL_FARM,rand(0,0))
						CHANGE_SKILL(SKILL_COOK,rand(8,9))
						CHANGE_SKILL(SKILL_ENGINE,rand(0,0))
						CHANGE_SKILL(SKILL_SURG,rand(0,0))
						CHANGE_SKILL(SKILL_MEDIC,rand(0,0))
						CHANGE_SKILL(SKILL_CLEAN,rand(8,9))
						CHANGE_SKILL(SKILL_CLIMB,rand(8,8))
						CHANGE_SKILL(SKILL_SWIM,rand(1,2))
						CHANGE_SKILL(SKILL_MUSIC, rand(2,6))
						CHANGE_SKILL(SKILL_KNIFE,rand(0,2))
						CHANGE_SKILL(SKILL_OBSERV, rand(8,9))
					if("Nun")
						CHANGE_SKILL(SKILL_MELEE,rand(5,5))
						CHANGE_SKILL(SKILL_RANGE,rand(6,6))
						CHANGE_SKILL(SKILL_FARM,rand(10,10))
						CHANGE_SKILL(SKILL_COOK,rand(11,12))
						CHANGE_SKILL(SKILL_ENGINE,rand(0,0))
						CHANGE_SKILL(SKILL_SURG,rand(11,11))
						CHANGE_SKILL(SKILL_MEDIC,rand(11,11))
						CHANGE_SKILL(SKILL_CLEAN,rand(12,12))
						CHANGE_SKILL(SKILL_CLIMB,rand(8,8))
						CHANGE_SKILL(SKILL_SWIM,rand(0,0))
						CHANGE_SKILL(SKILL_OBSERV, rand(8,9))
					if("Patriarch")
						CHANGE_SKILL(SKILL_MELEE,rand(9,9))
						CHANGE_SKILL(SKILL_RANGE, rand(7,7))
						CHANGE_SKILL(SKILL_FARM,rand(0,0))
						CHANGE_SKILL(SKILL_COOK,rand(9,9))
						CHANGE_SKILL(SKILL_ENGINE,rand(0,0))
						CHANGE_SKILL(SKILL_SURG,rand(8,8))
						CHANGE_SKILL(SKILL_MEDIC,rand(8,8))
						CHANGE_SKILL(SKILL_CLEAN,rand(6,6))
						CHANGE_SKILL(SKILL_CLIMB,rand(8,8))
						CHANGE_SKILL(SKILL_PARTY,rand(0,0))
						CHANGE_SKILL(SKILL_SWIM,rand(6,7))
						CHANGE_SKILL(SKILL_MUSIC, rand(0,0))
						CHANGE_SKILL(SKILL_OBSERV, rand(8,9))
					if("Hump")
						CHANGE_SKILL(SKILL_MELEE,rand(8,8))
						CHANGE_SKILL(SKILL_RANGE,rand(6,6))
						CHANGE_SKILL(SKILL_UNARM,rand(0,2))
						CHANGE_SKILL(SKILL_FARM,rand(0,0))
						CHANGE_SKILL(SKILL_COOK,rand(0,0))
						CHANGE_SKILL(SKILL_ENGINE,rand(12,13))
						CHANGE_SKILL(SKILL_CRAFT, 14)
						CHANGE_SKILL(SKILL_SURG,rand(0,0))
						CHANGE_SKILL(SKILL_MEDIC,rand(0,0))
						CHANGE_SKILL(SKILL_CLEAN,rand(0,0))
						CHANGE_SKILL(SKILL_MASON,rand(15,16))
						CHANGE_SKILL(SKILL_CLIMB, 11)
						CHANGE_SKILL(SKILL_SWIM,rand(8,9))
						CHANGE_SKILL(SKILL_OBSERV, rand(8,9))
						CHANGE_SKILL(SKILL_MINE,rand(13,13))
					if("Grayhound")
						CHANGE_SKILL(SKILL_MELEE,rand(10,10))
						CHANGE_SKILL(SKILL_RANGE,rand(9,9))
						CHANGE_SKILL(SKILL_UNARM,rand(1,2))
						CHANGE_SKILL(SKILL_FARM,rand(0,0))
						CHANGE_SKILL(SKILL_COOK,rand(0,0))
						CHANGE_SKILL(SKILL_ENGINE,rand(0,0))
						CHANGE_SKILL(SKILL_SURG,rand(0,0))
						CHANGE_SKILL(SKILL_CLIMB, 11)
						CHANGE_SKILL(SKILL_MEDIC,rand(0,0))
						CHANGE_SKILL(SKILL_CLEAN,rand(6,7))
						CHANGE_SKILL(SKILL_SWIM,rand(7,7))
						CHANGE_SKILL(SKILL_OBSERV, rand(8,9))
						CHANGE_SKILL(SKILL_BOAT, rand(0,0))
					if("Serpent")
						CHANGE_SKILL(SKILL_MELEE,rand(7,7))
						CHANGE_SKILL(SKILL_RANGE,rand(8,8))
						CHANGE_SKILL(SKILL_UNARM,rand(0,1))
						CHANGE_SKILL(SKILL_FARM,rand(0,0))
						CHANGE_SKILL(SKILL_COOK,rand(0,0))
						CHANGE_SKILL(SKILL_CLIMB,rand(8,8))
						CHANGE_SKILL(SKILL_ENGINE,rand(0,0))
						CHANGE_SKILL(SKILL_SURG,rand(13,13))
						CHANGE_SKILL(SKILL_MEDIC,rand(13,13))
						CHANGE_SKILL(SKILL_CLEAN,rand(0,0))
						CHANGE_SKILL(SKILL_OBSERV, rand(8,9))
						CHANGE_SKILL(SKILL_ALCH, rand(10,10))
					if("Chemsister")
						CHANGE_SKILL(SKILL_MELEE,rand(6,6))
						CHANGE_SKILL(SKILL_RANGE,rand(8,8))
						CHANGE_SKILL(SKILL_UNARM,rand(0,1))
						CHANGE_SKILL(SKILL_FARM,rand(0,0))
						CHANGE_SKILL(SKILL_COOK,rand(0,0))
						CHANGE_SKILL(SKILL_ENGINE,rand(0,0))
						CHANGE_SKILL(SKILL_SURG,rand(10,10))
						CHANGE_SKILL(SKILL_CLIMB,rand(8,8))
						CHANGE_SKILL(SKILL_MEDIC,rand(10,10))
						CHANGE_SKILL(SKILL_ALCH,rand(10,10))
						CHANGE_SKILL(SKILL_CLEAN,rand(8,9))
						CHANGE_SKILL(SKILL_OBSERV, rand(8,9))
					if("Esculap")
						CHANGE_SKILL(SKILL_MELEE,rand(9,9))
						CHANGE_SKILL(SKILL_RANGE,rand(11,11))
						CHANGE_SKILL(SKILL_UNARM,rand(0,1))
						CHANGE_SKILL(SKILL_FARM,rand(0,0))
						CHANGE_SKILL(SKILL_COOK,rand(0,0))
						CHANGE_SKILL(SKILL_CLIMB,rand(8,8))
						CHANGE_SKILL(SKILL_ENGINE,rand(0,0))
						CHANGE_SKILL(SKILL_SURG,rand(17,17))
						CHANGE_SKILL(SKILL_MEDIC,rand(17,17))
						CHANGE_SKILL(SKILL_CLEAN,rand(0,0))
						CHANGE_SKILL(SKILL_SWIM,rand(0,0))
						CHANGE_SKILL(SKILL_OBSERV, rand(8,9))
						CHANGE_SKILL(SKILL_ALCH, rand(13,13))
					if("Marduk")
						CHANGE_SKILL(SKILL_MELEE,rand(15,16))
						if(prob(20))
							CHANGE_SKILL(SKILL_MELEE,17)
						var/weaponSpecs = rand(0,3)
						switch(weaponSpecs)
							if(0)
								CHANGE_SKILL(SKILL_SWORD,rand(0,3))
								CHANGE_SKILL(SKILL_KNIFE,rand(0,3))
							if(1)
								CHANGE_SKILL(SKILL_SWORD,rand(0,3))
								CHANGE_SKILL(SKILL_STAFF,rand(0,3))
							if(2)
								CHANGE_SKILL(SKILL_STAFF,rand(0,3))
								CHANGE_SKILL(SKILL_SWING,rand(0,3))
							if(3)
								CHANGE_SKILL(SKILL_SWING,rand(0,3))
								CHANGE_SKILL(SKILL_SWING,rand(0,3))
						CHANGE_SKILL(SKILL_RANGE,rand(12,12))
						CHANGE_SKILL(SKILL_FARM,rand(0,0))
						CHANGE_SKILL(SKILL_COOK,rand(0,0))
						CHANGE_SKILL(SKILL_ENGINE,rand(0,0))
						CHANGE_SKILL(SKILL_SURG,rand(9,9))
						CHANGE_SKILL(SKILL_CLIMB, 13)
						CHANGE_SKILL(SKILL_MEDIC,rand(9,9))
						CHANGE_SKILL(SKILL_CLEAN,rand(0,0))
						CHANGE_SKILL(SKILL_SWIM,rand(11,12))
						CHANGE_SKILL(SKILL_OBSERV, rand(13,13))
						CHANGE_SKILL(SKILL_BOAT, rand(0,0))
					if("Tiamat")
						var/weaponSpecs = rand(0,3)
						switch(weaponSpecs)
							if(0)
								CHANGE_SKILL(SKILL_SWORD,rand(0,3))
								CHANGE_SKILL(SKILL_KNIFE,rand(0,3))
							if(1)
								CHANGE_SKILL(SKILL_SWORD,rand(0,3))
								CHANGE_SKILL(SKILL_STAFF,rand(0,3))
							if(2)
								CHANGE_SKILL(SKILL_STAFF,rand(0,3))
								CHANGE_SKILL(SKILL_SWING,rand(0,3))
							if(3)
								CHANGE_SKILL(SKILL_SWING,rand(0,3))
								CHANGE_SKILL(SKILL_SWING,rand(0,3))
						CHANGE_SKILL(SKILL_MELEE,rand(12,12))
						CHANGE_SKILL(SKILL_RANGE,rand(11,11))
						CHANGE_SKILL(SKILL_UNARM,rand(0,3))
						CHANGE_SKILL(SKILL_FARM,rand(0,0))
						CHANGE_SKILL(SKILL_COOK,rand(0,0))
						CHANGE_SKILL(SKILL_ENGINE,rand(0,0))
						CHANGE_SKILL(SKILL_SURG,rand(0,0))
						CHANGE_SKILL(SKILL_MEDIC,rand(0,0))
						CHANGE_SKILL(SKILL_CLEAN,rand(0,0))
						CHANGE_SKILL(SKILL_CLIMB,rand(13,13))
						CHANGE_SKILL(SKILL_SWIM,rand(11,12))
						CHANGE_SKILL(SKILL_OBSERV, rand(11,11))
						CHANGE_SKILL(SKILL_BOAT, rand(0,0))
					if("Baroness Bodyguard")
						CHANGE_SKILL(SKILL_MELEE,rand(9,9))
						CHANGE_SKILL(SKILL_RANGE,rand(9,9))
						CHANGE_SKILL(SKILL_UNARM,rand(0,2))
						CHANGE_SKILL(SKILL_FARM,rand(0,0))
						CHANGE_SKILL(SKILL_COOK,rand(0,0))
						CHANGE_SKILL(SKILL_ENGINE,rand(0,0))
						CHANGE_SKILL(SKILL_SURG,rand(0,0))
						CHANGE_SKILL(SKILL_MEDIC,rand(0,0))
						CHANGE_SKILL(SKILL_CLEAN,rand(0,0))
						CHANGE_SKILL(SKILL_CLIMB,rand(13,13))
						CHANGE_SKILL(SKILL_SWIM,rand(11,12))
						CHANGE_SKILL(SKILL_OBSERV, rand(11,11))
						CHANGE_SKILL(SKILL_BOAT, rand(0,0))
					if("Mercenary")
						CHANGE_SKILL(SKILL_MELEE,rand(11,11))
						CHANGE_SKILL(SKILL_RANGE,rand(8,8))
						CHANGE_SKILL(SKILL_UNARM,rand(0,2))
						CHANGE_SKILL(SKILL_CLIMB,rand(10,11))
						CHANGE_SKILL(SKILL_SWIM,rand(9,10))
						CHANGE_SKILL(SKILL_OBSERV, rand(10,10))
						CHANGE_SKILL(SKILL_SURG,rand(0,0))
						CHANGE_SKILL(SKILL_MEDIC,rand(0,0))
					if("Squire")
						var/weaponSpecs = rand(0,2)
						switch(weaponSpecs)
							if(0)
								CHANGE_SKILL(SKILL_SWORD,rand(1,2))
							if(1)
								CHANGE_SKILL(SKILL_STAFF,rand(1,2))
							if(2)
								CHANGE_SKILL(SKILL_SWING,rand(1,2))
						CHANGE_SKILL(SKILL_MELEE,rand(9,9))
						CHANGE_SKILL(SKILL_RANGE,rand(9,9))
						CHANGE_SKILL(SKILL_FARM,rand(0,0))
						CHANGE_SKILL(SKILL_COOK,rand(0,0))
						CHANGE_SKILL(SKILL_UNARM,rand(0,2))
						CHANGE_SKILL(SKILL_ENGINE,rand(0,0))
						CHANGE_SKILL(SKILL_SURG,rand(0,0))
						CHANGE_SKILL(SKILL_MEDIC,rand(0,0))
						CHANGE_SKILL(SKILL_CLEAN,rand(0,0))
						CHANGE_SKILL(SKILL_CLIMB,rand(12,12))
						CHANGE_SKILL(SKILL_STEAL,rand(9,9))
						CHANGE_SKILL(SKILL_SWIM,rand(10,10))
						CHANGE_SKILL(SKILL_OBSERV, rand(8,9))
						CHANGE_SKILL(SKILL_BOAT, rand(0,0))
					if("Scuff")
						CHANGE_SKILL(SKILL_MELEE,rand(8,8))
						CHANGE_SKILL(SKILL_RANGE,rand(8,8))
						CHANGE_SKILL(SKILL_FARM,rand(0,0))
						CHANGE_SKILL(SKILL_COOK,rand(0,0))
						CHANGE_SKILL(SKILL_ENGINE,rand(0,0))
						CHANGE_SKILL(SKILL_SURG,rand(6,6))
						CHANGE_SKILL(SKILL_MEDIC,rand(0,0))
						CHANGE_SKILL(SKILL_KNIFE,rand(1,3))
						CHANGE_SKILL(SKILL_CLEAN,rand(7,7))
						CHANGE_SKILL(SKILL_CLIMB,rand(12,12))
						CHANGE_SKILL(SKILL_STEAL,rand(11,11))
						CHANGE_SKILL(SKILL_OBSERV, rand(8,9))
					if("Urchin")
						CHANGE_SKILL(SKILL_MELEE,rand(5,5))
						CHANGE_SKILL(SKILL_RANGE,rand(5,5))
						CHANGE_SKILL(SKILL_KNIFE,rand(0,1))
						CHANGE_SKILL(SKILL_FARM,rand(0,0))
						CHANGE_SKILL(SKILL_COOK,rand(0,0))
						CHANGE_SKILL(SKILL_ENGINE,rand(0,0))
						CHANGE_SKILL(SKILL_SURG,rand(0,0))
						CHANGE_SKILL(SKILL_MEDIC,rand(0,0))
						CHANGE_SKILL(SKILL_CLEAN,rand(0,0))
						CHANGE_SKILL(SKILL_CLIMB,rand(12,12))
						CHANGE_SKILL(SKILL_STEAL,rand(10,10))
						CHANGE_SKILL(SKILL_OBSERV, rand(8,9))
					if("Tribunal Veteran")
						CHANGE_SKILL(SKILL_MELEE,rand(12,12))
						CHANGE_SKILL(SKILL_RANGE,rand(13,13))
						CHANGE_SKILL(SKILL_UNARM,rand(0,2))
						CHANGE_SKILL(SKILL_FARM,rand(0,0))
						CHANGE_SKILL(SKILL_COOK,rand(0,0))
						CHANGE_SKILL(SKILL_ENGINE,rand(0,0))
						CHANGE_SKILL(SKILL_SURG,rand(6,9))
						CHANGE_SKILL(SKILL_MEDIC,rand(6,9))
						CHANGE_SKILL(SKILL_CLEAN,rand(0,0))
						CHANGE_SKILL(SKILL_CLIMB,rand(8,8))
						CHANGE_SKILL(SKILL_STEAL,rand(0,9))
						CHANGE_SKILL(SKILL_OBSERV, rand(10,10))
						CHANGE_SKILL(SKILL_BOAT, rand(0,0))
					if("Incarn")
						CHANGE_SKILL(SKILL_MELEE,rand(12,12))
						CHANGE_SKILL(SKILL_UNARM,rand(0,2))
						CHANGE_SKILL(SKILL_RANGE,rand(13,13))
						CHANGE_SKILL(SKILL_FARM,rand(0,0))
						CHANGE_SKILL(SKILL_COOK,rand(0,0))
						CHANGE_SKILL(SKILL_ENGINE,rand(0,4))
						CHANGE_SKILL(SKILL_SURG,rand(9,9))
						CHANGE_SKILL(SKILL_MEDIC,rand(9,9))
						CHANGE_SKILL(SKILL_CLEAN,rand(0,0))
						CHANGE_SKILL(SKILL_CLIMB,rand(12,12))
						CHANGE_SKILL(SKILL_SWIM,rand(11,11))
						CHANGE_SKILL(SKILL_OBSERV, rand(8,9))
						CHANGE_SKILL(SKILL_BOAT, rand(3,6))
					if("Sheriff")
						CHANGE_SKILL(SKILL_MELEE,rand(10,10))
						CHANGE_SKILL(SKILL_RANGE,rand(14,17))
						CHANGE_SKILL(SKILL_UNARM,rand(1,2))
						CHANGE_SKILL(SKILL_FARM,rand(0,0))
						CHANGE_SKILL(SKILL_COOK,rand(9,9))
						CHANGE_SKILL(SKILL_ENGINE,rand(0,0))
						CHANGE_SKILL(SKILL_SURG,rand(9,9))
						CHANGE_SKILL(SKILL_MEDIC,rand(10,10))
						CHANGE_SKILL(SKILL_CLEAN,rand(0,0))
						CHANGE_SKILL(SKILL_CLIMB,rand(12,12))
						CHANGE_SKILL(SKILL_SWIM,rand(12,12))
						CHANGE_SKILL(SKILL_OBSERV, rand(11,12))
						CHANGE_SKILL(SKILL_BOAT, rand(0,0))
					if("Practicus")
						CHANGE_SKILL(SKILL_MELEE,rand(12,12))
						CHANGE_SKILL(SKILL_RANGE,rand(9,9))
						CHANGE_SKILL(SKILL_UNARM,rand(1,2))
						CHANGE_SKILL(SKILL_SWING,rand(1,2))
						CHANGE_SKILL(SKILL_FARM,rand(0,0))
						CHANGE_SKILL(SKILL_COOK,rand(0,0))
						CHANGE_SKILL(SKILL_ENGINE,rand(0,0))
						CHANGE_SKILL(SKILL_SURG,rand(7,7))
						CHANGE_SKILL(SKILL_MEDIC,rand(8,8))
						CHANGE_SKILL(SKILL_CLEAN,rand(0,0))
						CHANGE_SKILL(SKILL_CLIMB,rand(13,13))
						CHANGE_SKILL(SKILL_STEAL,rand(11,13))
						CHANGE_SKILL(SKILL_SWIM,rand(10,10))
						CHANGE_SKILL(SKILL_OBSERV, rand(11,11))
						CHANGE_SKILL(SKILL_BOAT, rand(0,0))
					if("Inquisitor")
						CHANGE_SKILL(SKILL_MELEE,rand(11,11))
						CHANGE_SKILL(SKILL_RANGE,rand(13,13))
						CHANGE_SKILL(SKILL_UNARM,rand(1,3))
						CHANGE_SKILL(SKILL_KNIFE,rand(1,3))
						CHANGE_SKILL(SKILL_SWING,rand(1,3))
						CHANGE_SKILL(SKILL_FARM,rand(0,0))
						CHANGE_SKILL(SKILL_COOK,rand(0,0))
						CHANGE_SKILL(SKILL_ENGINE,rand(0,0))
						CHANGE_SKILL(SKILL_SURG,rand(10,10))
						CHANGE_SKILL(SKILL_MEDIC,rand(10,10))
						CHANGE_SKILL(SKILL_CLEAN,rand(0,0))
						CHANGE_SKILL(SKILL_CLIMB,rand(13,13))
						CHANGE_SKILL(SKILL_SWIM,rand(12,12))
						CHANGE_SKILL(SKILL_OBSERV, rand(15,16))
						CHANGE_SKILL(SKILL_BOAT, rand(0,0))
					if("Bishop")
						CHANGE_SKILL(SKILL_MELEE,rand(0,0))
						CHANGE_SKILL(SKILL_RANGE,rand(7,7))
						CHANGE_SKILL(SKILL_FARM,rand(0,0))
						CHANGE_SKILL(SKILL_COOK,rand(0,0))
						CHANGE_SKILL(SKILL_ENGINE,rand(0,0))
						CHANGE_SKILL(SKILL_KNIFE,rand(1,3))
						CHANGE_SKILL(SKILL_SURG,rand(0,0))
						CHANGE_SKILL(SKILL_MEDIC,rand(0,0))
						CHANGE_SKILL(SKILL_CLEAN,rand(0,0))
						CHANGE_SKILL(SKILL_CLIMB,rand(8,8))
						CHANGE_SKILL(SKILL_OBSERV, rand(8,9))
					if("Bum")
						CHANGE_SKILL(SKILL_MELEE,rand(6,6))
						CHANGE_SKILL(SKILL_RANGE,rand(6,6))
						CHANGE_SKILL(SKILL_FARM,rand(0,0))
						CHANGE_SKILL(SKILL_COOK,rand(0,2))
						CHANGE_SKILL(SKILL_ENGINE,rand(0,0))
						CHANGE_SKILL(SKILL_SURG,rand(0,0))
						CHANGE_SKILL(SKILL_MEDIC,rand(0,0))
						CHANGE_SKILL(SKILL_CLEAN,rand(0,0))
						CHANGE_SKILL(SKILL_CLIMB,rand(10,12))
						CHANGE_SKILL(SKILL_STEAL,rand(5,10))
						CHANGE_SKILL(SKILL_SWIM,rand(0,0))
						CHANGE_SKILL(SKILL_UNARM,rand(0,1))
						CHANGE_SKILL(SKILL_OBSERV, rand(8,9))
					if("Misero")
						CHANGE_SKILL(SKILL_MELEE,rand(9,9))
						CHANGE_SKILL(SKILL_RANGE,rand(5,5))
						CHANGE_SKILL(SKILL_FARM,rand(0,0))
						CHANGE_SKILL(SKILL_COOK,rand(8,8))
						CHANGE_SKILL(SKILL_ENGINE,rand(0,0))
						CHANGE_SKILL(SKILL_CLEAN,rand(13,15))
						CHANGE_SKILL(SKILL_CLIMB,rand(8,8))
						CHANGE_SKILL(SKILL_SWIM,rand(5,5))
						CHANGE_SKILL(SKILL_UNARM,rand(0,2))
						CHANGE_SKILL(SKILL_SWING,rand(0,2))
						CHANGE_SKILL(SKILL_OBSERV, rand(8,9))
					if("Servant")
						CHANGE_SKILL(SKILL_MELEE,rand(5,5))
						CHANGE_SKILL(SKILL_RANGE,rand(5,5))
						CHANGE_SKILL(SKILL_FARM,rand(9,9))
						CHANGE_SKILL(SKILL_COOK,rand(10,10))
						CHANGE_SKILL(SKILL_ENGINE,rand(0,0))
						CHANGE_SKILL(SKILL_SURG,rand(0,0))
						CHANGE_SKILL(SKILL_MEDIC,rand(0,2))
						CHANGE_SKILL(SKILL_CLEAN,rand(10,10))
						CHANGE_SKILL(SKILL_CLIMB,rand(11,11))
						CHANGE_SKILL(SKILL_SWIM,rand(0,0))
						CHANGE_SKILL(SKILL_OBSERV, rand(8,9))
					if("Apprentice")
						CHANGE_SKILL(SKILL_MELEE,rand(8,8))
						CHANGE_SKILL(SKILL_RANGE,rand(5,5))
						CHANGE_SKILL(SKILL_FARM,rand(0,0))
						CHANGE_SKILL(SKILL_COOK,rand(0,0))
						CHANGE_SKILL(SKILL_ENGINE,rand(0,0))
						CHANGE_SKILL(SKILL_SURG,rand(0,0))
						CHANGE_SKILL(SKILL_MEDIC,rand(0,0))
						CHANGE_SKILL(SKILL_CLEAN,rand(0,2))
						CHANGE_SKILL(SKILL_SMITH,rand(11,13))
						CHANGE_SKILL(SKILL_CLIMB,rand(10,11))
						CHANGE_SKILL(SKILL_OBSERV, rand(8,9))
					if("Weaponsmith")
						CHANGE_SKILL(SKILL_MELEE,rand(9,9))
						CHANGE_SKILL(SKILL_RANGE,rand(5,5))
						CHANGE_SKILL(SKILL_FARM,rand(0,0))
						CHANGE_SKILL(SKILL_COOK,rand(0,0))
						CHANGE_SKILL(SKILL_ENGINE,rand(0,0))
						CHANGE_SKILL(SKILL_SURG,rand(0,0))
						CHANGE_SKILL(SKILL_MEDIC,rand(0,0))
						CHANGE_SKILL(SKILL_CLEAN,rand(0,0))
						CHANGE_SKILL(SKILL_MASON,rand(10,11))
						CHANGE_SKILL(SKILL_SMITH,rand(14,17))
						CHANGE_SKILL(SKILL_CLIMB,rand(8,8))
						CHANGE_SKILL(SKILL_UNARM,rand(0,2))
						CHANGE_SKILL(SKILL_OBSERV, rand(8,9))
					if("Armorsmith")
						CHANGE_SKILL(SKILL_MELEE,rand(9,9))
						CHANGE_SKILL(SKILL_RANGE,rand(5,5))
						CHANGE_SKILL(SKILL_FARM,rand(0,0))
						CHANGE_SKILL(SKILL_COOK,rand(0,0))
						CHANGE_SKILL(SKILL_ENGINE,rand(0,0))
						CHANGE_SKILL(SKILL_SURG,rand(0,0))
						CHANGE_SKILL(SKILL_MEDIC,rand(0,0))
						CHANGE_SKILL(SKILL_CLEAN,rand(0,0))
						CHANGE_SKILL(SKILL_MASON,rand(10,11))
						CHANGE_SKILL(SKILL_SMITH,rand(14,17))
						CHANGE_SKILL(SKILL_CLIMB,rand(8,8))
						CHANGE_SKILL(SKILL_UNARM,rand(0,2))
						CHANGE_SKILL(SKILL_OBSERV, rand(8,9))
					if("Metalsmith")
						CHANGE_SKILL(SKILL_MELEE,rand(9,9))
						CHANGE_SKILL(SKILL_RANGE,rand(5,5))
						CHANGE_SKILL(SKILL_FARM,rand(0,0))
						CHANGE_SKILL(SKILL_COOK,rand(0,0))
						CHANGE_SKILL(SKILL_ENGINE,rand(0,0))
						CHANGE_SKILL(SKILL_SURG,rand(0,0))
						CHANGE_SKILL(SKILL_MEDIC,rand(0,0))
						CHANGE_SKILL(SKILL_CLEAN,rand(0,0))
						CHANGE_SKILL(SKILL_MASON,rand(10,11))
						CHANGE_SKILL(SKILL_SMITH,rand(14,17))
						CHANGE_SKILL(SKILL_CLIMB,rand(8,8))
						CHANGE_SKILL(SKILL_UNARM,rand(0,2))
						CHANGE_SKILL(SKILL_OBSERV, rand(8,9))
			if(host.gender == FEMALE)
				if(GET_SKILL(SKILL_CLEAN) <= 7)
					CHANGE_SKILL(SKILL_CLEAN,rand(7,9))
				if(GET_SKILL(SKILL_COOK) <= 7)
					CHANGE_SKILL(SKILL_COOK,rand(7,9))
/******************************************/
/*     STATS, ST, HT, IT, DEX             */
/******************************************/
/mob/living/carbon
	var/datum/stat_holder/my_stats = null
	proc
		init_stats()
			var/datum/stat_holder/newStats = new
			newStats.host = src
			newStats.rand_stats()
			my_stats = newStats

proc/strToDamageModifier(var/strength, var/ht)
	var/diff = strength - ht
	var/baseDamage = 5

	if(diff < 0)
		var/parsedDiff = diff * -1
		for(var/x = 0; x < parsedDiff; x++)
			baseDamage -= rand(1, 3)
	if(diff > 0)
		for(var/x = 0; x < diff; x++)
			baseDamage += rand(4, 7)

	if(baseDamage <= 0){
		baseDamage = 3
	}
	return baseDamage

	//SISTEMA ANTIGO
	//ACHO QUE VAI SER PIOR QUE O ATUAL, SE DEUS QUISER O ATUAL É MELHOR

	switch(strength) //HAHAHAHAHAHAHAHAHAHAHAHAH AHHAHAH SIMM!!
		if(1) return 1
		if(2) return 2.5
		if(3) return 3
		if(4) return 5
		if(5) return 6
		if(6) return 8
		if(7) return 9
		if(8) return 10
		if(9) return 11
		if(10) return 12
		if(11) return 14
		if(12) return 17
		if(13) return 19
		if(14) return 24
		if(15) return 27
		if(16) return 30
		if(17) return 33
		if(18) return 36
		if(19) return 40
		if(20) return 42
		if(21) return 43
		if(22) return 44
		if(23) return 45
		if(24) return 46
		if(25) return 47
		if(26) return 49
		if(27) return 51
		if(29) return 53
		if(30) return 55
		if(31) return 57
		if(32) return 60
		if(32 to INFINITY)
			return rand(60, 80)

/obj/item/proc/getNewWeaponForce(var/st, var/ht){
	var/diff = st - 10
	var/newForce = force

	if(diff < 0) // 8 DE ST BATE EM 12
		var/parsedDiff = diff * -1
		var/sum = 0
		for(var/x = 0; x < parsedDiff; x++)
			sum += newForce / 12
			newForce -= sum
	if(diff > 0)
		var/sum = 0
		for(var/x = 0; x < diff; x++)
			sum += newForce / 10
			newForce += sum

	if(newForce < 0){
		newForce = 0
	}
	return newForce
}

//BASICAMENTE A PROC ABAIXO O PLANO É SER SUBSTITUIDA PELA DE CIMA
//A DE BAIXO É MUITO CAGADA E DEIXA TUDO ROUBADO!!!
proc/strToDamageModifierItem(var/strength, var/ht)
	switch(strength)
		if(1 to 5)
			return 1//+3 +3

		if(6 to 9)
			return 3.5//+2 +5

		if(10 to 12)
			return 4

		if(12 to 14)
			return 4.8//+3 +5

		if(14 to 16)
			return 5

		if(16 to 20)
			return 7
		if(20 to 25)
			return 30
		if(25 to 30)
			return 40
		if(31 to INFINITY)
			return 80


/datum/stat_holder
	var/mob/living/carbon/human/host = null
	var/datum/stat_mod/list/stat_mods = list()
	var/list/stats = list(
	STAT_ST  = 10,
	STAT_DX  = 10,
	STAT_HT  = 10,
	STAT_IN  = 10,
	STAT_PR  = 0,
	STAT_WP  = 1,
	STAT_IM  = 0,
	STAT_SPD = 0)

/datum/stat_holder/proc/get_stat(var/x)
	switch(x)
		if(STAT_PR)
			return round(max(stats[STAT_PR] + stats[STAT_IN],0))
		if(STAT_IM)
			return round(max(stats[STAT_HT] + stats[STAT_IM],0))
		else
			return round(max(stats[x],0))

/datum/stat_holder/proc/change_stat(var/stat, var/amount)
	if(stats[stat] != null)
		stats[stat] += amount
	if(stats[stat] < 0)
		stats[stat] = 0

/datum/stat_holder/proc/set_stat(var/stat, var/amount)
	if(stats[stat] != null)
		stats[stat] = amount
	if(stats[stat] < 0)
		stats[stat] = 0

/datum/stat_holder/proc/job_stats(var/job)

	if(job && istype(job, /datum/job))
		var/datum/job/J = job
		for(var/i in 1 to J.stats_mods.len)
			stats[i] += J.stats_mods[i]

	host.special_load()
	if(FAT in host.mutations)
		change_stat(STAT_ST, 1)
		change_stat(STAT_DX, -2)
		change_stat(STAT_HT, 1)
	if(host.gender == FEMALE && !host.has_penis())
		change_stat(STAT_ST, -1)
	if(host.age >= 50)
		change_stat(STAT_ST, -1)
		change_stat(STAT_HT, -1)
		change_stat(STAT_IN, 2)
		change_stat(STAT_PR, 2)
	if(host.age <= 16)
		set_stat(STAT_ST, rand(7,9))
		set_stat(STAT_HT, rand(8,10))

/datum/stat_holder/proc/rand_stats()
	for(var/i in 1 to 4)
		change_stat(i,BASE_STAT_CHANGE)

/**************************************
************HUMAN MY NIGGA*************
***************************************/

proc/skilltxt(var/skill)
	switch(skill)
		if(-INFINITY to 2)
			return "<span class='notthatbadactually'>Worthless"
		if(3 to 5)
			return "<span class='notthatbadactually'>Inept"
		if(6 to 9)
			return "<span class='notthatbadactually'>Novice"
		if(10 to 11)
			return "<span class='notthatbadactually'>Skilled"
		if(12 to 13)
			return "<span class='notthatbadactually'>Adept"
		if(14 to 15)
			return "<span class='holyshituractuallysogooditmakesmecringedudelol'>Expert"
		if(16)
			return "<span class='holyshituractuallysogooditmakesmecringedudelol'>Master"
		if(17 to INFINITY)
			return "<span class='legendary'>Legendary"



proc/skilltxt2(var/skill)
	switch(skill)
		if(-INFINITY to 0)
			return "<span class='notthatbadactually'>0"
		if(1)
			return "<span class='notthatbadactually'>1"
		if(2)
			return "<span class='notthatbadactually'>2"
		if(3)
			return "<span class='notthatbadactually'>3"
		if(4)
			return "<span class='notthatbadactually'>4"
		if(5)
			return "<span class='notthatbadactually'>5"
		if(6)
			return "<span class='notthatbadactually'>6"
		if(7)
			return "<span class='notthatbadactually'>7"
		if(8)
			return "<span class='notthatbadactually'>8"
		if(9)
			return "<span class='notthatbadactually'>9"
		if(10 to INFINITY)
			return "<span class='notthatbadactually'>10"

/**************************************
************HUMAN MY NIGGA*************
***************************************/
/mob/living/carbon/human/verb/check_skills()
	set hidden = 1
	var/list/combat  = list()
	var/list/general = list()
	for(var/skill_id in 1 to my_skills.skills_holder.len)
		var/datum/skill/S = get_skill_data(skill_id,my_skills)
		var/value = get_skill_value(skill_id,my_skills)
		var/skill_num = skill_id
		if(value <= 0)
			continue
		if(S.combat_skill == TRUE)
			combat += skill_num
		else
			general += skill_num
	var/msg = "<div class='firstdivskill'><div class='skilldiv'>"

	msg += "<span class='holyshituractuallysogooditmakesmecringedudelol'>* Combat Skills:</span>\n"
	for(var/i in combat)
		var/value = get_skill_value(i,my_skills)
		var/datum/skill/S = get_skill_data(i,my_skills)
		if(S.showing_text)
			msg += "<span class='notthatbadactually'>- [S.name]:</span> [skilltxt(value)]</span>\n"
		else
			msg += "<span class='notthatbadactually'>- [S.name]:</span> [skilltxt2(value)]</span>\n"

	msg += "<hr class='linexd'>"

	msg += "<span class='holyshituractuallysogooditmakesmecringedudelol'>* General Skills:</span>\n"

	for(var/i in general)
		var/value = get_skill_value(i,my_skills)
		var/datum/skill/S = get_skill_data(i,my_skills)
		if(S.showing_text)
			msg += "<span class='notthatbadactually'>- [S.name]:</span> [skilltxt(value)]</span>\n"
		else
			msg += "<span class='notthatbadactually'>- [S.name]:</span> [skilltxt2(value)]</span>\n"

	msg += "\n"
	for(var/datum/perk/PERK in src.perks)
		msg += "<span class='perks'>*[PERK.description] </span> "
	to_chat(src, "[msg]", 23)

/mob/living/carbon/human/verb/check_skills_rmb()
	set hidden = 1
	var/list/combat  = list()
	var/list/general = list()
	for(var/skill_id in 1 to my_skills.skills_holder.len)
		var/datum/skill/S = get_skill_data(skill_id,my_skills)
		var/skill_num = skill_id
		if(S.combat_skill == TRUE)
			combat += skill_num
		else
			general += skill_num
	var/msg = "<div class='firstdivskill'><div class='skilldiv'>"

	msg += "<span class='holyshituractuallysogooditmakesmecringedudelol'>* Combat Skills:</span>\n"
	for(var/i in combat)
		var/value = get_skill_value(i,my_skills)
		var/datum/skill/S = get_skill_data(i,my_skills)
		if(S.showing_text)
			msg += "<span class='notthatbadactually'>- [S.name]:</span> [skilltxt(value)]</span>\n"
		else
			msg += "<span class='notthatbadactually'>- [S.name]:</span> [skilltxt2(value)]</span>\n"

	msg += "<hr class='linexd'>"

	msg += "<span class='holyshituractuallysogooditmakesmecringedudelol'>* General Skills:</span>\n"

	for(var/i in general)
		var/value = get_skill_value(i,my_skills)
		var/datum/skill/S = get_skill_data(i,my_skills)
		if(S.showing_text)
			msg += "<span class='notthatbadactually'>- [S.name]:</span> [skilltxt(value)]</span>\n"
		else
			msg += "<span class='notthatbadactually'>- [S.name]:</span> [skilltxt2(value)]</span>\n"
	msg += "\n"
	for(var/datum/perk/PERK in src.perks)
		msg += "<span class='perks'>*[PERK.description]*</span> "
	to_chat(src, "[msg]", 23)




#define SKILL_SUCESSO 1
#define SKILL_FALHA 0

proc/skillcheck(var/skill, var/requirement, var/show_message, var/mob/user, var/message = "I have failed to do this.")//1 - 100
	skill = (skill+2)*10
	var/mob/living/carbon/human/H = user
	if(requirement > skill)
		if(prob(H.happiness*4))
			return SKILL_SUCESSO
		else if(prob(skill-10+max(0, H.happiness)))
			return SKILL_SUCESSO
		else
			return SKILL_FALHA
	else if(skill > requirement)
		if(prob(skill+H?.happiness+rand(4,9)))
			return SKILL_SUCESSO
		else
			return SKILL_FALHA


proc/statcheck(var/stat, var/requirement, var/show_message, var/mob/user, var/message = "I have failed to do this.")//1 - 100
	var/dice = "1d20"
	if(stat < requirement)
		var/H = roll(dice)
		var/requiredroll = requirement - 1
		if(requiredroll < H)
			return 1
		else
			return 0
	else
		var/rola = roll("1d5")
		if(rola == 1)
			return 0
		else
			return 1

/mob/living/carbon/human/proc/gainWP(var/displaymsg, var/wpgain)
	if(src.special == "doublewp" && wpgain > 0)
		wpgain = wpgain * 2
	src.my_stats.change_stat(STAT_WP , wpgain)
	if(displaymsg)
		src << 'sound/effects/wisewoman.ogg'
		if(wpgain < 0)
			to_chat(src, "<span class='combatbold'>LOST [wpgain]WP!</span>")
		else
			to_chat(src, "<span class='passive'>GAINED [wpgain]WP!</span>")

/mob/living/carbon/human/proc/learn_skill(var/skill, var/from, var/extramodif = 0, var/show = FALSE)
	if(!mind)
		return
	if(!skill || !my_skills.skills_holder[skill] || my_skills.GET_SKILL(skill) >= my_skills.max_value)
		return
	var/datum/skill/S = get_skill_data(skill,my_skills)
	var/skill_value = my_skills.GET_SKILL(skill)
	var/learn_bonus = extramodif
	var/learning_mod = 0
	var/mob/living/carbon/human/H
	var/obj/structure/lifeweb/statue/dummy/D
	if(mind)
		learning_mod += mind.learning_modif

	if(from)
		if(istype(from, /mob/living/carbon/human))
			H = from
			if(H.my_skills.GET_SKILL(skill) <= my_skills.GET_SKILL(skill))
				return
			if(H.mind)
				learn_bonus += H.mind.teaching_modif
				if(H.check_perk(/datum/perk/ref/teaching))
					learn_bonus += 3
		else if(istype(from, /obj/structure/lifeweb/statue/dummy))
			D = from
			learn_bonus += D.teaching_mod

	learning_mod += learn_bonus
	var/list/roll_result = roll3d6(src,my_stats.get_stat(STAT_IN), learning_mod, TRUE,TRUE)
	var/margin = roll_result[GP_MARGIN]
	margin += learn_bonus + learning_mod - skill_value
	if(margin <= 0)
		margin = 1
	if(H)
		margin += max((H.my_skills.GET_SKILL(skill) - my_skills.GET_SKILL(skill)) * 10, 1)
	if(S.combat_skill)
		margin = max(round(margin / 2), 1)
	switch(roll_result[GP_RESULT])
		if(GP_CRITSUCC)
			mind.learning_collector[skill] += (margin * 2)
			if(H)
				to_chat(src, "<span class='passivebold'>Oh, I get it!</span>")
			else if(D)
				var/text_skill = skill2typerson(round((mind.learning_collector[skill]) / (max(1, skill_value))))
				to_chat(src, "<span class='passivebold'>Oh, I get it!</span>")
				to_chat(src, "<span class='passivebold'><div class='box'>I understand: [text_skill]</span></span>")
		if(GP_SUCC)
			mind.learning_collector[skill] += margin
			if(H)
				to_chat(src, "<span class='passive'>Oh, I get it.</span>")
			else if(D)
				var/text_skill = skill2typerson(round((mind.learning_collector[skill]) / (max(1, skill_value))))
				to_chat(src, "<span class='passive'><div class='box'>I understand: [text_skill]</span></span>")
		if(GP_FAIL)
			if(H)
				to_chat(src, "<span class='combat'>It's hard to understand.</span>")
				H.want_punch(src)
		if(GP_CRITFAIL)
			if(H)
				to_chat(src, "<span class='combatbold'>It's very hard to understand!</span>")
				rotate_plane()
				H.want_punch(src)

	check_learning(skill)

/mob/living/carbon/human/proc/check_learning(var/skill)
	if(!mind)
		return FALSE
	if(!mind.learning_collector[skill])
		return FALSE
	var/skill_value = 1
	if(!(my_skills.GET_SKILL(skill) <= 0))
		skill_value = my_skills.GET_SKILL(skill)

	var/learned = mind.learning_collector[skill]
	var/maxlearn = 20 * skill_value

	if(learned < maxlearn)
		return FALSE

	my_skills.ADD_SKILL(skill, 1)
	mind.learning_collector[skill] = 0
	to_chat(src, "<span class='holyshituractuallysogooditmakesmecringedudelol'>I learned more about [lowertext(my_skills.GET_SKILL_NAME(skill))]!</span>")
	return TRUE


proc/skill2typerson(var/amount)
	switch(amount)
		if(0)
			return "...................."
		if(1)
			return "•..................."
		if(2)
			return "••.................."
		if(3)
			return "•••................."
		if(4)
			return "••••................"
		if(5)
			return "•••••..............."
		if(6)
			return "••••••.............."
		if(7)
			return "•••••••............."
		if(8)
			return "••••••••............"
		if(9)
			return "•••••••••..........."
		if(10)
			return "••••••••••.........."
		if(11)
			return "•••••••••••........."
		if(12)
			return "••••••••••••........"
		if(13)
			return "•••••••••••••......."
		if(14)
			return "••••••••••••••......"
		if(15)
			return "•••••••••••••••....."
		if(16)
			return "••••••••••••••••...."
		if(17)
			return "•••••••••••••••••..."
		if(18)
			return "••••••••••••••••••.."
		if(19)
			return "•••••••••••••••••••."
		if(20 to INFINITY)
			return "••••••••••••••••••••"

/mob/living/carbon/human/proc/teach_others()
	if(stat || !(length(my_skills.skills_holder))) return
	var/list/skills_list = list()
	for(var/skill_id in 1 to my_skills.skills_holder.len)
		var/datum/skill/S = get_skill_data(skill_id,my_skills)
		var/value = get_skill_value(skill_id,my_skills)
		if(!S)
			continue
		if(value <= 0)
			continue
		skills_list[S.name] = skill_id
	if(!length(skills_list))
		to_chat(src, "<span class='combat'>I'm dumb...</span>")
		return
	var/teaching_skill = input(src, "Which skill i want to teach them?", "Thinking") in skills_list
	if(!teaching_skill) return
	var/teaching_text = sanitize(input(src, "What i want to say?", "Telling", "") as message)
	if(!teaching_text) return

	say(teaching_text)

	var/text_power = round(length(teaching_text) / 20)

	for(var/mob/living/carbon/human/M in view(3))
		if(M == src) continue
		if(M.my_skills.GET_SKILL(skills_list[teaching_skill]) >= my_skills.GET_SKILL(skills_list[teaching_skill])) continue
		M.ready_to_learn(text_power, src, skills_list[teaching_skill])


/mob/living/carbon/human/proc/ready_to_learn(var/text_power, var/mob/living/carbon/human/who, var/skill)
	var/to_delete = "[skill]-[world.time]"
	my_skills.prepare_learn[to_delete] = list(skill, who, text_power)
	spawn(50)
		if(to_delete in my_skills.prepare_learn)
			my_skills.prepare_learn.Remove(to_delete)

/mob/living/carbon/human/proc/spendWP()
	if(my_stats.get_stat(STAT_WP) <= 0)	return
	if(willpower_active)
		to_chat(src, "I already am spending my willpower.")
		return
	var/wpPicked

	var/multiplier = 1
	var/list/WPList = list("+1 ST" = STAT_ST,"+1 DX" = STAT_DX,"+1 IN" = STAT_IN, "+1 HT" = STAT_HT, "+2 PR" = STAT_PR, "+4 IM" = STAT_IM, "Resist Disgust")
	if(src.check_perk(/datum/perk/heroiceffort))
		multiplier = 2
		WPList += "Stamina Effort"

	WPList += "(CANCEL)"

	wpPicked = input(src,"Please, select an effort!","Triumph of the Will",wpPicked) in WPList
	if(willpower_active)
		to_chat(src, "I already am spending my willpower.")
		return

	var/wp_target //this is shit
	var/amount
	if(WPList[wpPicked]) //this means we have a stat
		wp_target = WPList[wpPicked]
		amount = text2num(copytext(wpPicked,2,3)) //this is even worse
		var/list/stat_list = list(
		STAT_ST  = 0,
		STAT_DX  = 0,
		STAT_HT  = 0,
		STAT_IN  = 0,
		STAT_PR  = 0,
		STAT_WP  = 0,
		STAT_IM  = 0,
		STAT_SPD = 0)
		stat_list[wp_target] = amount*multiplier
		src.my_stats.add_mod("spent_WP", stat_list, time = 1200, override = TRUE, override_timer = TRUE)
		willpower_active = num2text(amount*multiplier) + copytext(wpPicked,3,0)
		spawn(1200)
			willpower_active = ""
			to_chat(src, "The Willpower effect wears off.")
		gainWP(1, -1)
		spawn(5)
			src << 'sound/effects/wpspent.ogg'
	else
		switch(wpPicked)
			if("Resist Disgust")
				src.resisting_disgust = TRUE
				willpower_active = "Resisting Disgust"
				spawn(1200)
					src.resisting_disgust = FALSE
					willpower_active = ""
					to_chat(src, "The Willpower effect wears off.")
			if("Stamina Effort")
				src.stamina_loss = max(0, stamina_loss-50)
			if("(CANCEL)")
				return
		gainWP(1, -1)
		spawn(5)
			src << 'sound/effects/wpspent.ogg'
