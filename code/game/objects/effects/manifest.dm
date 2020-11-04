/obj/effect/manifest
	name = "manifest"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "x"

/obj/effect/manifest/New()

	src.invisibility = 101
	return

/obj/effect/manifest/proc/manifest()
	var/dat = "<B>Crew Manifest</B>:<BR>"
	for(var/thing in GLOB.human_list)
		var/mob/living/carbon/human/M = thing
		dat += text("    <B>[]</B> -  []<BR>", M.name, M.get_assignment())
	var/obj/item/paper/P = new /obj/item/paper( src.loc )
	P.info = dat
	P.name = "paper- 'Crew Manifest'"
	//SN src = null
	qdel(src)
	return
