/obj/structure/spawner/nether
	name = "netherworld link"
	desc = null //see examine()
	icon_state = "nether"
	max_integrity = 50
	spawn_time = 600 //1 minute
	max_mobs = 15
	icon = 'icons/mob/nest.dmi'
	spawn_text = "crawls through"
	mob_types = list(/mob/living/basic/netherworld/migo, /mob/living/basic/netherworld, /mob/living/basic/netherworld/blankbody)
	faction = list("nether")

/obj/structure/spawner/nether/Initialize(mapload)
	.=..()
	START_PROCESSING(SSprocessing, src)

/obj/structure/spawner/nether/examine(mob/user)
	. = ..()
	if(isskeleton(user))
		. += "A direct link to another dimension full of creatures very happy to see you. [SPAN_NICEGREEN("You can see your house from here!")]"
	else
		. += "A direct link to another dimension full of creatures not very happy to see you. [SPAN_WARNING("Entering the link would be a very bad idea.")]"

/obj/structure/spawner/nether/attack_hand(mob/user)
	. = ..()
	if(isskeleton(user))
		to_chat(user, SPAN_NOTICE("You don't feel like going home yet..."))
	else
		user.visible_message(SPAN_WARNING("[user] is violently pulled into the link!"), \
							SPAN_USERDANGER("Touching the portal, you are quickly pulled through into a world of unimaginable horror!"))
		contents.Add(user)

/obj/structure/spawner/nether/process()
	for(var/mob/living/M in contents)
		if(M)
			playsound(src, 'sound/magic/demon_consume.ogg', 50, TRUE)
			M.adjustBruteLoss(60)
			new /obj/effect/gibspawner/generic(get_turf(M), M.dna)
			if(M.stat == DEAD)
				var/mob/living/basic/netherworld/blankbody/blank
				blank = new(loc)
				blank.name = "[M]"
				blank.desc = "It's [M], but [M.p_their()] flesh has an ashy texture, and [M.p_their()] face is featureless save an eerie smile."
				visible_message(SPAN_WARNING("[M] reemerges from the link!"))
				blank.held_body = M
				M.forceMove(blank)

/obj/structure/spawner/nether/deconstruct(disassembled)
	for(var/mob/living/M in contents)
		if(M)
			M.forceMove(loc)
	return ..()

