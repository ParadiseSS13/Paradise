/atom/movable/verb/pull()
	set name = "Pull"
	set category = null
	set src in oview(1)

	if(Adjacent(usr))
		usr.start_pulling(src)
	return

/atom/verb/point()
	set name = "Point To"
	set category = null
	set popup_menu = 0
	set src in oview()
	var/atom/this = src//detach proc from src
	src = null

	if(!usr || !isturf(usr.loc))
		return
	if(usr.stat || usr.restrained())
		return
	if(usr.status_flags & FAKEDEATH)
		return
	if(usr.next_move > world.time)
		return

	var/tile = get_turf(this)
	if (!tile)
		return

	var/P = new /obj/effect/decal/point(tile)
	usr.changeNext_move(CLICK_CD_POINT)
	spawn (20)
		if(P)	qdel(P)

	usr.visible_message("<b>[usr]</b> points to [this]")
