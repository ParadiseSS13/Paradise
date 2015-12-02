//gang_datum.dm
//Datum-based gangs

/datum/gang
	var/name = "ERROR"
	var/color = "white"
	var/color_hex = "#FFFFFF"
	var/list/datum/mind/gangsters = list() //gang B Members
	var/list/datum/mind/bosses = list() //gang A Bosses
	var/list/obj/item/device/gangtool/gangtools = list()
	var/style
	var/fighting_style = "normal"
	var/list/territory = list()
	var/list/territory_new = list()
	var/list/territory_lost = list()
	var/dom_timer = "OFFLINE"
	var/dom_attempts = 2
	var/points = 15
	var/datum/atom_hud/antag/ganghud

/datum/gang/New(loc,gangname)
	if(!gang_colors_pool.len)
		message_admins("WARNING: Maximum number of gangs have been exceeded!")
		throw EXCEPTION("Maximum number of gangs has been exceeded")
		return
	else
		color = pick(gang_colors_pool)
		gang_colors_pool -= color
		switch(color)
			if("red")
				color_hex = "#DA0000"
			if("orange")
				color_hex = "#FF9300"
			if("yellow")
				color_hex = "#FFF200"
			if("green")
				color_hex = "#A8E61D"
			if("blue")
				color_hex = "#00B7EF"
			if("purple")
				color_hex = "#DA00FF"

	name = (gangname ? gangname : pick(gang_name_pool))
	gang_name_pool -= name
	if(name == "Sleeping Carp")
		fighting_style = "martial"

	ganghud = new()
	log_game("The [name] Gang has been created. Their gang color is [color].")

/datum/gang/proc/add_gang_hud(datum/mind/recruit_mind)
	ganghud.join_hud(recruit_mind.current)
	ticker.mode.set_antag_hud(recruit_mind.current, ((recruit_mind in bosses) ? "gang_boss" : "gangster"))

/datum/gang/proc/remove_gang_hud(datum/mind/defector_mind)
	ganghud.leave_hud(defector_mind.current)
	ticker.mode.set_antag_hud(defector_mind.current, null)

/datum/gang/proc/domination(modifier=1)
	dom_timer = get_domination_time(src) * modifier
	set_security_level("delta")
	SSshuttle.emergencyNoEscape = 1

//////////////////////////////////////////// OUTFITS


//Used by recallers when purchasing a gang outfit. First time a gang outfit is purchased the buyer decides a gang style which is stored so gang outfits are uniform
/datum/gang/proc/gang_outfit(mob/living/carbon/user,obj/item/device/gangtool/gangtool)
	if(!user || !gangtool)
		return 0
	if(!gangtool.can_use(user))
		return 0

	var/gang_style_list = list("Gang Colors","Black Suits","White Suits","Leather Jackets","Leather Overcoats","Puffer Jackets","Military Jackets","Tactical Turtlenecks","Soviet Uniforms")
	if(!style && (user.mind in ticker.mode.get_gang_bosses()))	//Only the boss gets to pick a style
		style = input("Pick an outfit style.", "Pick Style") as null|anything in gang_style_list

	if(gangtool.can_use(user) && (gangtool.outfits >= 1))
		var/outfit_path
		switch(style)
			if(null || "Gang Colors")
				outfit_path = text2path("/obj/item/clothing/under/color/[color]")
			if("Black Suits")
				outfit_path = /obj/item/clothing/under/suit_jacket/charcoal
			if("White Suits")
				outfit_path = /obj/item/clothing/under/suit_jacket/white
			if("Puffer Jackets")
				outfit_path = /obj/item/clothing/suit/jacket/puffer
			if("Leather Jackets")
				outfit_path = /obj/item/clothing/suit/jacket/leather
			if("Leather Overcoats")
				outfit_path = /obj/item/clothing/suit/jacket/leather/overcoat
			if("Military Jackets")
				outfit_path = /obj/item/clothing/suit/jacket/miljacket
			if("Soviet Uniforms")
				outfit_path = /obj/item/clothing/under/soviet
			if("Tactical Turtlenecks")
				outfit_path = /obj/item/clothing/under/syndicate

		if(outfit_path)
			var/obj/item/clothing/outfit = new outfit_path(user.loc)
			outfit.armor = list(melee = 20, bullet = 30, laser = 10, energy = 10, bomb = 20, bio = 0, rad = 0)
			outfit.desc += " Tailored for the [name] Gang to offer the wearer moderate protection against ballistics and physical trauma."
			outfit.gang = src
			user.put_in_any_hand_if_possible(outfit)
			return 1

	return 0


//////////////////////////////////////////// MESSAGING


/datum/gang/proc/message_gangtools(message,beep=1,warning)
	if(!gangtools.len || !message)
		return
	for(var/obj/item/device/gangtool/tool in gangtools)
		var/mob/living/mob = get(tool.loc,/mob/living)
		if(mob && mob.mind && mob.stat == CONSCIOUS)
			if(mob.mind.gang_datum == src)
				mob << "<span class='[warning ? "warning" : "notice"]'>\icon[tool] [message]</span>"
				if(beep)
					playsound(mob.loc, 'sound/machines/twobeep.ogg', 50, 1)


//////////////////////////////////////////// INCOME


/datum/gang/proc/income()
	if(!bosses.len)
		return

	var/added_names = ""
	var/lost_names = ""

	//Re-add territories that were reclaimed, so if they got tagged over, they can still earn income if they tag it back before the next status report
	var/list/reclaimed_territories = territory_new & territory_lost
	territory |= reclaimed_territories
	territory_new -= reclaimed_territories
	territory_lost -= reclaimed_territories

	//Process lost territories
	for(var/area in territory_lost)
		if(lost_names != "")
			lost_names += ", "
		lost_names += "[territory_lost[area]]"
		territory -= area

	//Count uniformed gangsters
	var/uniformed = 0
	for(var/datum/mind/gangmind in (gangsters|bosses))
		if(ishuman(gangmind.current))
			var/mob/living/carbon/human/gangster = gangmind.current
			//Gangster must be alive and on station
			if((gangster.stat == DEAD) || (gangster.z > ZLEVEL_STATION))
				continue

			var/obj/item/clothing/outfit
			var/obj/item/clothing/gang_outfit
			if(gangster.w_uniform)
				outfit = gangster.w_uniform
				if(outfit.gang == src)
					gang_outfit = outfit
			if(gangster.wear_suit)
				outfit = gangster.wear_suit
				if(outfit.gang == src)
					gang_outfit = outfit

			if(gang_outfit)
				gangster << "<span class='notice'>The [src] Gang's influence grows as you wear [gang_outfit].</span>"
				uniformed ++

	//Calculate and report influence growth
	var/message = "<b>[src] Gang Status Report:</b><BR>*---------*<br>"
	if(isnum(dom_timer))
		var/new_time = max(180,dom_timer - (uniformed * 4) - (territory.len * 2))
		if(new_time < dom_timer)
			message += "Takeover shortened by [dom_timer - new_time] seconds for defending [territory.len] territories and [uniformed] uniformed gangsters.<BR>"
			dom_timer = new_time
		message += "<b>[dom_timer] seconds remain</b> in hostile takeover.<BR>"
	else
		var/points_new = min(999,points + 15 + (uniformed * 2) + territory.len)
		if(points_new != points)
			message += "Gang influence has increased by [points_new - points] for defending [territory.len] territories and [uniformed] uniformed gangsters.<BR>"
		points = points_new
		message += "Your gang now has <b>[points] influence</b>.<BR>"

	//Process new territories
	for(var/area in territory_new)
		if(added_names != "")
			added_names += ", "
		added_names += "[territory_new[area]]"
		territory += area

	//Report territory changes
	message += "<b>[territory_new.len] new territories:</b><br><i>[added_names]</i><br>"
	message += "<b>[territory_lost.len] territories lost:</b><br><i>[lost_names]</i><br>"

	//Clear the lists
	territory_new = list()
	territory_lost = list()

	var/control = round((territory.len/start_state.num_territories)*100, 1)
	message += "Your gang now has <b>[control]% control</b> of the station.<BR>*---------*"
	message_gangtools(message)

	//Increase outfit stock
	for(var/obj/item/device/gangtool/tool in gangtools)
		tool.outfits = min(tool.outfits+1,5)