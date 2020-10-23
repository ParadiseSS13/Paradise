//  Beacon randomly spawns in space
//	When a non-traitor (no special role in /mind) uses it, he is given the choice to become a traitor
//	If he accepts there is a random chance he will be accepted, rejected, or rejected and killed
//	Bringing certain items can help improve the chance to become a traitor


/obj/machinery/syndicate_beacon
	name = "ominous beacon"
	desc = "This looks suspicious..."
	icon = 'icons/obj/device.dmi'
	icon_state = "syndbeacon"

	anchored = 1
	density = 1

	var/temptext = ""
	var/selfdestructing = 0
	var/charges = 1

/obj/machinery/syndicate_beacon/attack_hand(var/mob/user as mob)
	usr.set_machine(src)
	var/dat = {"<meta charset="UTF-8"><font color=#005500><i>Scanning [pick("retina pattern", "voice print", "fingerprints", "dna sequence")]...<br>Identity confirmed,<br></i></font>"}
	if(istype(user, /mob/living/carbon/human) || istype(user, /mob/living/silicon/ai))
		if(is_special_character(user))
			dat += "<font color=#07700><i>Operative record found. Greetings, Agent [user.name].</i></font><br>"
		else if(charges < 1)
			dat += "<TT>Connection severed.</TT><BR>"
		else
			var/honorific = "Mr."
			if(user.gender == FEMALE)
				honorific = "Ms."
			dat += "<font color=red><i>Identity not found in operative database. What can the Syndicate do for you today, [honorific] [user.name]?</i></font><br>"
			if(!selfdestructing)
				dat += "<br><br><A href='?src=[UID()];betraitor=1;traitormob=\ref[user]'>\"[pick("I want to switch teams.", "I want to work for you.", "Let me join you.", "I can be of use to you.", "You want me working for you, and here's why...", "Give me an objective.", "How's the 401k over at the Syndicate?")]\"</A><BR>"
	dat += temptext
	user << browse(dat, "window=syndbeacon")
	onclose(user, "syndbeacon")

/obj/machinery/syndicate_beacon/Topic(href, href_list)
	if(..())
		return 1
	if(href_list["betraitor"])
		if(charges < 1)
			src.updateUsrDialog()
			return
		var/mob/M = locate(href_list["traitormob"])
		if(M.mind.special_role)
			temptext = "<i>We have no need for you at this time. Have a pleasant day.</i><br>"
			src.updateUsrDialog()
			return
		charges -= 1
		switch(rand(1,2))
			if(1)
				temptext = "<font color=red><i><b>Double-crosser. You planned to betray us from the start. Allow us to repay the favor in kind.</b></i></font>"
				src.updateUsrDialog()
				spawn(rand(50,200)) selfdestruct()
				return
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/N = M
			var/objective = "Free Objective"
			switch(rand(1,100))
				if(1 to 50)
					objective = "Steal [pick("a hand teleporter", "the Captain's antique laser gun", "a jetpack", "the Captain's ID", "the Captain's jumpsuit")]."
				if(51 to 60)
					objective = "Destroy 70% or more of the station's plasma tanks."
				if(61 to 70)
					objective = "Cut power to 80% or more of the station's tiles."
				if(71 to 80)
					objective = "Destroy the AI."
				if(81 to 90)
					objective = "Kill all monkeys aboard the station."
				else
					objective = "Make certain at least 80% of the station evacuates on the shuttle."

			var/datum/objective/custom_objective = new(objective)
			custom_objective.owner = N.mind
			N.mind.objectives += custom_objective
			var/datum/objective/escape/escape_objective = new
			escape_objective.owner = N.mind
			N.mind.objectives += escape_objective

			var/datum/antagonist/traitor/T = new()
			T.give_objectives = FALSE
			N.mind.add_antag_datum(T)

			to_chat(M, "<B>You have joined the ranks of the Syndicate and become a traitor to the station!</B>")
			message_admins("[key_name_admin(N)] has accepted a traitor objective from a syndicate beacon.")


	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return


/obj/machinery/syndicate_beacon/proc/selfdestruct()
	selfdestructing = 1
	spawn() explosion(src.loc, rand(3,8), rand(1,3), 1, 10)



////////////////////////////////////////
//Singularity beacon
////////////////////////////////////////
/obj/machinery/power/singularity_beacon
	name = "ominous beacon"
	desc = "This looks suspicious..."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "beacon"

	anchored = 0
	density = 1
	layer = MOB_LAYER - 0.2 //so people can't hide it and it's REALLY OBVIOUS
	stat = 0

	var/active = 0
	var/icontype = "beacon"


/obj/machinery/power/singularity_beacon/proc/Activate(mob/user = null)
	if(surplus() < 1500)
		if(user)
			to_chat(user, "<span class='notice'>The connected wire doesn't have enough current.</span>")
		return
	for(var/thing in GLOB.singularities)
		var/obj/singularity/singulo = thing
		if(singulo.z == z)
			singulo.target = src
	icon_state = "[icontype]1"
	active = 1
	START_PROCESSING(SSmachines, src)
	if(user)
		to_chat(user, "<span class='notice'>You activate the beacon.</span>")


/obj/machinery/power/singularity_beacon/proc/Deactivate(mob/user = null)
	for(var/thing in GLOB.singularities)
		var/obj/singularity/singulo = thing
		if(singulo.target == src)
			singulo.target = null
	icon_state = "[icontype]0"
	active = 0
	if(user)
		to_chat(user, "<span class='notice'>You deactivate the beacon.</span>")


/obj/machinery/power/singularity_beacon/attack_ai(mob/user as mob)
	return


/obj/machinery/power/singularity_beacon/attack_hand(var/mob/user as mob)
	if(anchored)
		return active ? Deactivate(user) : Activate(user)
	else
		to_chat(user, "<span class='warning'>You need to screw the beacon to the floor first!</span>")
		return


/obj/machinery/power/singularity_beacon/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(active)
		to_chat(user, "<span class='warning'>You need to deactivate the beacon first!</span>")
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(anchored)
		anchored = FALSE
		to_chat(user, "<span class='notice'>You unscrew the beacon from the floor.</span>")
		disconnect_from_network()
		return
	else
		if(!connect_to_network())
			to_chat(user, "This device must be placed over an exposed cable.")
			return
		anchored = TRUE
		to_chat(user, "<span class='notice'>You screw the beacon to the floor and attach the cable.</span>")

/obj/machinery/power/singularity_beacon/Destroy()
	if(active)
		Deactivate()
	return ..()

//stealth direct power usage
/obj/machinery/power/singularity_beacon/process()
	if(!active)
		return PROCESS_KILL

	if(surplus() >= 1500)
		add_load(1500)
	else
		Deactivate()

/obj/machinery/power/singularity_beacon/syndicate
	icontype = "beaconsynd"
	icon_state = "beaconsynd0"
