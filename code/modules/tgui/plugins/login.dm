/**
 * tgui login
 *
 * Allows the handling of logins using IDs within tgui.
 *
 * Two key procs:
 * * [/obj/proc/tgui_login_act] - Call in your tgui_act() proc to catch any login actions and handle them.
 * * [/obj/proc/tgui_login_data] - Call in your tgui_data() proc to pass login info.
 *
 * How to use (DM side):
 * 1. Call [/obj/proc/tgui_login_act] at the start of your tgui_act() proc
 * 2. Call [/obj/proc/tgui_login_data] in your tgui_data() proc while passing the data list
 * 3. In your object, call [/obj/proc/tgui_login_get] to get the current login state.
 * 4. Optional: call [/obj/proc/tgui_login_attackby] in your attackby() to make the login process easier.
 *
 * How to use (JS side): Use the <LoginScreen /> and <LoginInfo /> interfaces.
 */

GLOBAL_LIST(tgui_logins)

/**
  * Call this from a proc that is called in tgui_act() to process login actions
  *
  * Arguments:
  * * action - The called action
  * * params - The params to the action
  */
/obj/proc/tgui_login_act(action = "", params)
	. = null
	switch(action)
		if("login_insert")
			var/datum/tgui_login/state = tgui_login_get()
			if(state.id) // An ID is already inserted, eject it
				return tgui_login_eject(state = state)
			else // No ID, attempt to insert one in
				return tgui_login_insert(usr.get_active_hand(), state = state)
		if("login_eject")
			return tgui_login_eject()
		if("login_login")
			return tgui_login_login(text2num(params["login_type"]))
		if("login_logout")
			return tgui_login_logout()

/**
  * Appends login state data.
  *
  * Arguments:
  * * data - The data list to be returned
  * * user - The user calling tgui_data()
  * * state - The current login state
  */
/obj/proc/tgui_login_data(list/data, mob/user, datum/tgui_login/state = tgui_login_get())
	data["loginState"] = list(
		"id" = state.id ? state.id.name : null,
		"name" = state.name,
		"rank" = state.rank,
		"logged_in" = state.logged_in,
	)
	data["isAI"] = isAI(user)
	data["isRobot"] = isrobot(user)
	data["isAdmin"] = user.can_admin_interact()

/**
  * Convenience function to perform login actions when
  * the source object is hit by specific items.
  *
  * Arguments:
  * * O - The object
  * * user - The user
  */
/obj/proc/tgui_login_attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/card/id) && tgui_login_insert(O))
		tgui_interact(user)
		return TRUE

/**
  * Attempts to insert an object as an ID.
  *
  * Arguments:
  * * O - The object to try inserting
  * * state - The current login state
  */
/obj/proc/tgui_login_insert(obj/item/O, datum/tgui_login/state = tgui_login_get())
	if(state.id)
		return

	if(istype(O, /obj/item/card/id))
		// Move the ID inside
		usr.drop_item()
		O.forceMove(src)

		// Update the state
		state.id = O

		return TRUE

/**
  * Attempts to eject the inserted ID.
  *
  * Arguments:
  * * state - The current login state
  */
/obj/proc/tgui_login_eject(datum/tgui_login/state = tgui_login_get())
	if(!state.id)
		return

	// Drop the ID
	state.id.forceMove(loc)
	if(ishuman(usr) && !usr.get_active_hand())
		usr.put_in_hands(state.id)

	// Update the state
	state.id = null

	return TRUE

/**
  * Attempts to log in with the given login type.
  *
  * Arguments:
  * * login_type - The login type: LOGIN_TYPE_NORMAL (checks for inserted ID), LOGIN_TYPE_AI, LOGIN_TYPE_ROBOT and LOGIN_TYPE_ADMIN
  * * state - The current login state
  */
/obj/proc/tgui_login_login(login_type = LOGIN_TYPE_NORMAL, datum/tgui_login/state = tgui_login_get())
	if(state.logged_in)
		return

	if(state.id && login_type == LOGIN_TYPE_NORMAL)
		if(check_access(state.id))
			state.name = state.id.registered_name
			state.rank = state.id.assignment
			state.access = state.id.access
	else if(login_type == LOGIN_TYPE_AI && isAI(usr))
		state.name = usr.name
		state.rank = "AI"
	else if(login_type == LOGIN_TYPE_ROBOT && isrobot(usr))
		var/mob/living/silicon/robot/R = usr
		state.name = usr.name
		state.rank = "[R.modtype] [R.braintype]"
	else if(login_type == LOGIN_TYPE_ADMIN && usr.can_admin_interact())
		state.name = "*CONFIDENTIAL*"
		state.rank = "CentComm Secure Connection"
		state.access = get_all_accesses() + get_all_centcom_access()

	state.logged_in = TRUE
	tgui_login_on_login(state = state)

	return TRUE

/**
  * Attempts to log out.
  *
  * Arguments:
  * * state - The current login state
  */
/obj/proc/tgui_login_logout(datum/tgui_login/state = tgui_login_get())
	if(!state.logged_in)
		return

	state.name = ""
	state.rank = ""
	state.access = null
	state.logged_in = FALSE
	tgui_login_on_logout(state = state)

	return TRUE

/**
  * Returns (or creates) the login state for the source object.
  *
  * Arguments:
  * * state - The current login state
  */
/obj/proc/tgui_login_get()
	RETURN_TYPE(/datum/tgui_login)
	. = LAZYACCESS(GLOB.tgui_logins, UID())
	if(!.)
		LAZYINITLIST(GLOB.tgui_logins)
		. = GLOB.tgui_logins[UID()] = new /datum/tgui_login

/**
  * Called on successful login.
  *
  * Arguments:
  * * state - The current login state
  */
/obj/proc/tgui_login_on_login(datum/tgui_login/state = tgui_login_get())
	return

/**
  * Called on successful logout.
  *
  * Arguments:
  * * state - The current login state
  */
/obj/proc/tgui_login_on_logout(datum/tgui_login/state = tgui_login_get())
	return

/**
  * Login state (there should be only one for one datum)
  */
/datum/tgui_login
	var/obj/item/card/id/id = null
	var/name = ""
	var/rank = ""
	var/list/access = null
	var/logged_in = FALSE

/datum/tgui_login/New(id, name, rank, access)
	src.id = id
	src.name = name
	src.rank = rank
	src.access = access
