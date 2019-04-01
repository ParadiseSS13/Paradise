// Point controlling procs

/mob/camera/blob/proc/can_buy(var/cost = 15)
	if(blob_points < cost)
		to_chat(src, "<span class='warning'>You cannot afford this!</span>")
		return 0
	add_points(-cost)
	return 1

// Power verbs

/mob/camera/blob/verb/transport_core()
	set category = "Blob"
	set name = "Jump to Core"
	set desc = "Transport back to your core."

	if(blob_core)
		src.loc = blob_core.loc

/mob/camera/blob/verb/jump_to_node()
	set category = "Blob"
	set name = "Jump to Node"
	set desc = "Transport back to a selected node."

	if(blob_nodes.len)
		var/list/nodes = list()
		for(var/i = 1; i <= blob_nodes.len; i++)
			nodes["Blob Node #[i]"] = blob_nodes[i]
		var/node_name = input(src, "Choose a node to jump to.", "Node Jump") in nodes
		var/obj/structure/blob/node/chosen_node = nodes[node_name]
		if(chosen_node)
			src.loc = chosen_node.loc

/mob/camera/blob/verb/toggle_node_req()
	set category = "Blob"
	set name = "Toggle Node Requirement"
	set desc = "Toggle requiring nodes to place resource and factory blobs."
	nodes_required = !nodes_required
	if(nodes_required)
		to_chat(src, "<span class='warning'>You now require a nearby node or core to place factory and resource blobs.</span>")
	else
		to_chat(src, "<span class='warning'>You no longer require a nearby node or core to place factory and resource blobs.</span>")

/mob/camera/blob/verb/create_shield_power()
	set category = "Blob"
	set name = "Create/Upgrade Shield Blob (15)"
	set desc = "Create/Upgrade a shield blob. Using this on an existing shield blob turns it into a reflective blob, capable of reflecting most energy projectiles but making it much weaker than usual to brute attacks."

	var/turf/T = get_turf(src)
	create_shield(T)

/mob/camera/blob/proc/create_shield(var/turf/T)

	var/obj/structure/blob/B = locate(/obj/structure/blob) in T
	var/obj/structure/blob/shield/S = locate(/obj/structure/blob/shield) in T

	if(!S)
		if(!B)//We are on a blob
			to_chat(src, "There is no blob here!")
			return

		else if(!istype(B, /obj/structure/blob/normal))
			to_chat(src, "Unable to use this blob, find a normal one.")
			return

		else if(!can_buy(15))
			return

		B.color = blob_reagent_datum.color
		B.change_to(/obj/structure/blob/shield)
	else

		if(istype(S, /obj/structure/blob/shield/reflective))
			to_chat(src, "<span class='warning'>There's already a reflector blob here!</span>")
			return


		else if(S.health < S.maxHealth * 0.5)
			to_chat(src, "<span class='warning'>This shield blob is too damaged to be modified properly!</span>")
			return

		else if (!can_buy(15))
			return

		to_chat(src, "<span class='warning'>You secrete a reflective ooze over the shield blob, allowing it to reflect energy projectiles at the cost of reduced intregrity.</span>")

		S.change_to(/obj/structure/blob/shield/reflective)
		S.color = blob_reagent_datum.color
	return

/mob/camera/blob/verb/create_resource()
	set category = "Blob"
	set name = "Create Resource Blob (40)"
	set desc = "Create a resource tower which will generate points for you."


	var/turf/T = get_turf(src)

	if(!T)
		return

	var/obj/structure/blob/B = (locate(/obj/structure/blob) in T)

	if(!B)//We are on a blob
		to_chat(src, "There is no blob here!")
		return

	if(!istype(B, /obj/structure/blob/normal))
		to_chat(src, "Unable to use this blob, find a normal one.")
		return

	for(var/obj/structure/blob/resource/blob in orange(4, T))
		to_chat(src, "There is a resource blob nearby, move more than 4 tiles away from it!")
		return

	if(nodes_required)
		if(!(locate(/obj/structure/blob/node) in orange(3, T)) && !(locate(/obj/structure/blob/core) in orange(4, T)))
			to_chat(src, "<span class='warning'>You need to place this blob closer to a node or core!</span>")
			return //handholdotron 2000

	if(!can_buy(40))
		return

	B.color = blob_reagent_datum.color
	B.change_to(/obj/structure/blob/resource)
	var/obj/structure/blob/resource/R = locate() in T
	if(R)
		R.overmind = src

	return

/mob/camera/blob/verb/create_node()
	set category = "Blob"
	set name = "Create Node Blob (60)"
	set desc = "Create a Node."


	var/turf/T = get_turf(src)

	if(!T)
		return

	var/obj/structure/blob/B = (locate(/obj/structure/blob) in T)

	if(!B)//We are on a blob
		to_chat(src, "There is no blob here!")
		return

	if(!istype(B, /obj/structure/blob/normal))
		to_chat(src, "Unable to use this blob, find a normal one.")
		return

	for(var/obj/structure/blob/node/blob in orange(5, T))
		to_chat(src, "There is another node nearby, move more than 5 tiles away from it!")
		return

	if(!can_buy(60))
		return

	B.change_to(/obj/structure/blob/node)
	var/obj/structure/blob/node/R = locate() in T
	if(R)
		R.adjustcolors(blob_reagent_datum.color)
		R.overmind = src
	return


/mob/camera/blob/verb/create_factory()
	set category = "Blob"
	set name = "Create Factory Blob (60)"
	set desc = "Create a Spore producing blob."


	var/turf/T = get_turf(src)

	if(!T)
		return

	var/obj/structure/blob/B = locate(/obj/structure/blob) in T
	if(!B)
		to_chat(src, "You must be on a blob!")
		return

	if(!istype(B, /obj/structure/blob/normal))
		to_chat(src, "Unable to use this blob, find a normal one.")
		return

	for(var/obj/structure/blob/factory/blob in orange(7, T))
		to_chat(src, "There is a factory blob nearby, move more than 7 tiles away from it!")
		return

	if(nodes_required)
		if(!(locate(/obj/structure/blob/node) in orange(3, T)) && !(locate(/obj/structure/blob/core) in orange(4, T)))
			to_chat(src, "<span class='warning'>You need to place this blob closer to a node or core!</span>")
			return //handholdotron 2000

	if(!can_buy(60))
		return

	B.change_to(/obj/structure/blob/factory)
	B.color = blob_reagent_datum.color
	var/obj/structure/blob/factory/R = locate() in T
	if(R)
		R.overmind = src
	return


/mob/camera/blob/verb/create_blobbernaut()
	set category = "Blob"
	set name = "Create Blobbernaut (20)"
	set desc = "Create a powerful blob-being, a Blobbernaut"

	var/turf/T = get_turf(src)

	if(!T)
		return

	var/obj/structure/blob/B = locate(/obj/structure/blob) in T
	if(!B)
		to_chat(src, "You must be on a blob!")
		return

	if(!istype(B, /obj/structure/blob/factory))
		to_chat(src, "Unable to use this blob, find a factory blob.")
		return

	if(!can_buy(20))
		return

	var/mob/living/simple_animal/hostile/blob/blobbernaut/blobber = new /mob/living/simple_animal/hostile/blob/blobbernaut (get_turf(B))
	if(blobber)
		qdel(B)
	blobber.color = blob_reagent_datum.complementary_color
	blobber.overmind = src
	blob_mobs.Add(blobber)
	return


/mob/camera/blob/verb/relocate_core()
	set category = "Blob"
	set name = "Relocate Core (80)"
	set desc = "Relocates your core to the node you are on, your old core will be turned into a node."


	var/turf/T = get_turf(src)

	if(!T)
		return

	var/obj/structure/blob/node/B = locate(/obj/structure/blob/node) in T
	if(!B)
		to_chat(src, "You must be on a blob node!")
		return

	if(!can_buy(80))
		return

	// The old switcharoo.
	var/turf/old_turf = blob_core.loc
	blob_core.loc = T
	B.loc = old_turf
	return


/mob/camera/blob/verb/revert()
	set category = "Blob"
	set name = "Remove Blob"
	set desc = "Removes a blob. You will receive 30% cost refund for special Blob structures."

	var/turf/T = get_turf(src)
	remove_blob(T)

/mob/camera/blob/proc/remove_blob(var/turf/T)

	var/obj/structure/blob/B = locate(/obj/structure/blob) in T
	if(!T)
		return
	if(!B)
		to_chat(src, "<span class='warning'>There is no blob there!</span>")
		return
	if(B.point_return < 0)
		to_chat(src, "<span class='warning'>Unable to remove this blob.</span>")
		return
	if(max_blob_points < B.point_return + blob_points)
		to_chat(src, "<span class='warning'>You have too many resources to remove this blob!</span>")
		return
	if(B.point_return)
		add_points(B.point_return)
		to_chat(src, "<span class='notice'>Gained [B.point_return] resources from removing \the [B].</span>")
	qdel(B)
	return


/mob/camera/blob/verb/expand_blob_power()
	set category = "Blob"
	set name = "Expand/Attack Blob (5)"
	set desc = "Attempts to create a new blob in this tile. If the tile isn't clear we will attack it, which might clear it."

	var/turf/T = get_turf(src)
	expand_blob(T)

/mob/camera/blob/proc/expand_blob(var/turf/T)
	if(!T)
		return

	if(!can_attack())
		return
	var/obj/structure/blob/B = locate() in T
	if(B)
		to_chat(src, "There is a blob here!")
		return

	var/obj/structure/blob/OB = locate() in circlerange(T, 1)
	if(!OB)
		to_chat(src, "There is no blob adjacent to you.")
		return

	if(!can_buy(5))
		return
	last_attack = world.time
	OB.expand(T, 0, blob_reagent_datum.color)
	for(var/mob/living/L in T)
		if("blob" in L.faction) //no friendly fire
			continue
		var/mob_protection = L.get_permeability_protection()
		blob_reagent_datum.reaction_mob(L, TOUCH, 25, 1, mob_protection)
		blob_reagent_datum.send_message(L)
	OB.color = blob_reagent_datum.color
	return


/mob/camera/blob/verb/rally_spores_power()
	set category = "Blob"
	set name = "Rally Spores (5)"
	set desc = "Rally the spores to move to your location."

	var/turf/T = get_turf(src)
	rally_spores(T)

/mob/camera/blob/proc/rally_spores(var/turf/T)

	if(!can_buy(5))
		return

	to_chat(src, "You rally your spores.")

	var/list/surrounding_turfs = block(locate(T.x - 1, T.y - 1, T.z), locate(T.x + 1, T.y + 1, T.z))
	if(!surrounding_turfs.len)
		return

	for(var/mob/living/simple_animal/hostile/blob/blobspore/BS in GLOB.living_mob_list)
		if(isturf(BS.loc) && get_dist(BS, T) <= 35)
			BS.LoseTarget()
			BS.Goto(pick(surrounding_turfs), BS.move_to_delay)
	return


/mob/camera/blob/verb/split_consciousness()
	set category = "Blob"
	set name = "Split consciousness (100) (One use)"
	set desc = "Expend resources to attempt to produce another sentient overmind."

	if(split_used)
		to_chat(src, "<span class='warning'>You have already produced an offspring.</span>")
		return
	if(is_offspring)
		to_chat(src, "<span class='warning'>You cannot split as an offspring of another Blob.</span>")
		return
	if(!blob_nodes || !blob_nodes.len)
		to_chat(src, "<span class='warning'>A node is required to birth your offspring...</span>")
		return
	var/obj/structure/blob/node/N = locate(/obj/structure/blob) in blob_nodes
	if(!N)
		to_chat(src, "<span class='warning'>A node is required to birth your offspring...</span>")
		return
	
	if(!can_buy(100))
		return

	split_used = TRUE
	
	new /obj/structure/blob/core/ (get_turf(N), 200, null, blob_core.point_rate, "offspring")
	qdel(N)

	if(ticker && ticker.mode.name == "blob")
		var/datum/game_mode/blob/BL = ticker.mode
		BL.blobwincount += initial(BL.blobwincount)


/mob/camera/blob/verb/blob_broadcast()
	set category = "Blob"
	set name = "Blob Broadcast"
	set desc = "Speak with your blob spores and blobbernauts as your mouthpieces. This action is free."

	var/speak_text = input(usr, "What would you like to say with your minions?", "Blob Broadcast", null) as text

	if(!speak_text)
		return
	else
		to_chat(usr, "You broadcast with your minions, <B>[speak_text]</B>")
	for(var/mob/living/simple_animal/hostile/blob_minion in blob_mobs)
		blob_minion.say(speak_text)
	return

/mob/camera/blob/verb/create_storage()
	set category = "Blob"
	set name = "Create Storage Blob (40)"
	set desc = "Create a storage tower which will store extra resources for you. This increases your max resource cap by 50."


	var/turf/T = get_turf(src)

	if(!T)
		return

	var/obj/structure/blob/B = (locate(/obj/structure/blob) in T)

	if(!B)//We are on a blob
		to_chat(src, "There is no blob here!")
		return

	if(!istype(B, /obj/structure/blob/normal))
		to_chat(src, "Unable to use this blob, find a normal one.")
		return

	for(var/obj/structure/blob/storage/blob in orange(3, T))
		to_chat(src, "There is a storage blob nearby, move more than 4 tiles away from it!")
		return

	if(!can_buy(40))
		return

	B.color = blob_reagent_datum.color
	B.change_to(/obj/structure/blob/storage)
	var/obj/structure/blob/storage/R = locate() in T
	if(R)
		R.overmind = src
		R.update_max_blob_points(50)

	return


/mob/camera/blob/verb/chemical_reroll()
	set category = "Blob"
	set name = "Reactive Chemical Adaptation (50)"
	set desc = "Replaces your chemical with a random, different one."

	if(!can_buy(50))
		return

	var/datum/reagent/blob/B = pick((subtypesof(/datum/reagent/blob) - blob_reagent_datum.type))
	blob_reagent_datum = new B

	color = blob_reagent_datum.complementary_color

	for(var/obj/structure/blob/BL in blobs)
		BL.adjustcolors(blob_reagent_datum.color)

	for(var/mob/living/simple_animal/hostile/blob/BLO)
		BLO.adjustcolors(blob_reagent_datum.complementary_color)

	to_chat(src, "Your reagent is now: <b><font color=\"[blob_reagent_datum.color]\">[blob_reagent_datum.name]</b></font> - [blob_reagent_datum.description]")

/mob/camera/blob/verb/blob_help()
	set category = "Blob"
	set name = "*Blob Help*"
	set desc = "Help on how to blob."
	to_chat(src, "<b>As the overmind, you can control the blob!</b>")
	to_chat(src, "Your blob reagent is: <b><font color=\"[blob_reagent_datum.color]\">[blob_reagent_datum.name]</b></font> - [blob_reagent_datum.description]")
	to_chat(src, "<b>You can expand, which will attack people, damage objects, or place a Normal Blob if the tile is clear.</b>")
	to_chat(src, "<i>Normal Blobs</i> will expand your reach and can be upgraded into special blobs that perform certain functions.")
	to_chat(src, "<b>You can upgrade normal blobs into the following types of blob:</b>")
	to_chat(src, "<i>Shield Blobs</i> are strong and expensive blobs which take more damage. In additon, they are fireproof and can block air, use these to protect yourself from station fires. Upgrading them again will result in a <i>Reflective blob</i>, capable of reflecting laser projectiles at the cost of the strong blob's extra health.")
	to_chat(src, "<i>Resource Blobs</i> are blobs which produce more resources for you, build as many of these as possible to consume the station. This type of blob must be placed near node blobs or your core to work.")
	to_chat(src, "<i>Factory Blobs</i> are blobs that spawn blob spores which will attack nearby enemies. This type of blob must be placed near node blobs or your core to work.")
	to_chat(src, "<i>Blobbernauts</i> can be produced from factories for a cost, and are hard to kill, powerful, but ultimately dumb. The factory used to create one will be destroyed in the process.")
	to_chat(src, "<i>Storage Blobs</i> are storage towers which will store extra resources for you. This increases your max resource cap by 50.")
	to_chat(src, "<i>Node Blobs</i> are blobs which grow, like the core. Like the core it can activate resource and factory blobs.")
	to_chat(src, "<b>In addition to the buttons on your HUD, there are a few click shortcuts to speed up expansion and defense.</b>")
	to_chat(src, "<b>Shortcuts:</b> Click = Expand Blob <b>|</b> CTRL Click = Create Shield Blob <b>|</b> Middle Mouse Click = Rally Spores <b>|</b> Alt Click = Remove Blob")
	to_chat(src, "Attempting to talk will send a message to all other <b>overminds</b>, allowing you to coordinate with them.")