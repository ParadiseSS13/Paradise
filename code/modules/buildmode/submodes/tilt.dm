/datum/buildmode_mode/tilting
	key = "tilt"

	/// The thing we're tilting over
	var/atom/movable/tilter
	var/crush_damage = 25
	var/crit_chance = 0
	var/datum/tilt_crit/forced_crit
	var/weaken_time = 4 SECONDS
	var/knockdown_time = 14 SECONDS
	var/ignore_gravity = TRUE
	var/should_rotate = TRUE
	var/rotation_angle
	var/rightable = TRUE
	var/block_interactions_until_righted = TRUE



/datum/buildmode_mode/tilting/show_help(mob/user)
	to_chat(user, "<span class='notice'>***********************************************************</span>")
	to_chat(user, "<span class='notice'>Left Mouse Button on obj/mob      = Select atom to tilt</span>")
	to_chat(user, "<span class='notice'>Right Mouse Button on turf/obj/mob = Tilt selected atom onto target</span>")
	to_chat(user, "<span class='notice'>Right Mouse Button + Alt          = Untilt selected atom</span>")
	to_chat(user, "<span class='warning'>Right-click the main action button to customize tilting behavior.</span>")
	to_chat(user, "<span class='notice'>***********************************************************</span>")

/datum/buildmode_mode/tilting/change_settings(mob/user)
	crush_damage = input(user, "Crush Damage", "Damage", initial(crush_damage)) as num|null
	crit_chance = input(user, "Crit Chance (out of 100)", "Crit chance", 0) as num|null
	if(crit_chance > 0)
		var/forced_crit_path = input(user, "Force a specific crit?", "Forced Crit", null) as null|anything in GLOB.tilt_crits
		if(forced_crit_path)
			forced_crit = GLOB.tilt_crits[forced_crit_path]
	weaken_time = input(user, "How long to weaken (in seconds)?", "Weaken Time", 4) as num|null
	weaken_time = weaken_time SECONDS
	knockdown_time = input(user, "How long to knockdown (in seconds)?", "Knockdown Time", 12) as num|null
	knockdown_time = knockdown_time SECONDS
	ignore_gravity = alert(user, "Ignore gravity?", "Ignore gravity", "Yes", "No") == "Yes"
	should_rotate = alert(user, "Should it rotate on falling?", "Should rotate", "Yes", "No") == "Yes"
	if(should_rotate)
		rotation_angle = input(user, "Which angle to rotate at? (if empty, defaults to 90 degrees in either direction)", "Rotation angle", 0) as num|null
		rightable = alert(user, "Should it be rightable with alt-click?", "Rightable", "Yes", "No") == "Yes"
		if(rightable)
			block_interactions_until_righted = alert(user, "Should it block interactions until righted (by alt-clicking)?", "Block interactions", "Yes", "No") == "Yes"

/datum/buildmode_mode/tilting/handle_click(mob/user, params, atom/movable/object)
	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")
	var/right_click = pa.Find("right")
	var/alt_click = pa.Find("alt")

	if(left_click)
		if(!ismovable(object))
			return
		tilter = object
		to_chat(user, "Selected object '[tilter]' to tilt.")
	if(right_click)
		if(!tilter)
			to_chat(user, "<span class='warning'>You need to select something to tilt (or untilt) first.</span>")
			return
		if(tilter.GetComponent(/datum/component/tilted) && alt_click)
			tilter.untilt(duration = 0)
			log_admin("Build Mode: [key_name(user)] has righted [tilter] ([tilter.x],[tilter.y],[tilter.z])")
			return

		if(!object || isnull(get_turf(object)))
			to_chat(user, "<span class='warning'>You need to select a target first.</span>")
			return

		tilter.fall_and_crush(get_turf(object), crush_damage, prob(crit_chance), 2, forced_crit, weaken_time, knockdown_time, ignore_gravity, should_rotate, rotation_angle, rightable, block_interactions_until_righted)

		log_admin("Build Mode: [key_name(user)] tilted [tilter] onto [ADMIN_COORDJMP(object)]")
