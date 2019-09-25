#define SDQL_qdel_datum(d) qdel(d)
//datum may be null, but it does need to be a typed var
#define NAMEOF(datum, X) (#X || ##datum.##X)

#define SDQL2_STATE_ERROR 0
#define SDQL2_STATE_IDLE 1
#define SDQL2_STATE_PRESEARCH 2
#define SDQL2_STATE_SEARCHING 3
#define SDQL2_STATE_EXECUTING 4
#define SDQL2_STATE_SWITCHING 5
#define SDQL2_STATE_HALTING 6

#define SDQL2_VALID_OPTION_TYPES list("proccall", "select", "priority", "autogc" , "sequential")
#define SDQL2_VALID_OPTION_VALUES list("async", "blocking", "force_nulls", "skip_nulls", "high", "normal", "keep_alive" , "true")

#define SDQL2_OPTION_SELECT_OUTPUT_SKIP_NULLS			(1<<0)
#define SDQL2_OPTION_BLOCKING_CALLS						(1<<1)
#define SDQL2_OPTION_HIGH_PRIORITY						(1<<2)		//High priority SDQL query, allow using almost all of the tick.
#define SDQL2_OPTION_DO_NOT_AUTOGC						(1<<3)
#define SDQL2_OPTION_SEQUENTIAL							(1<<4)

#define SDQL2_OPTIONS_DEFAULT		(SDQL2_OPTION_SELECT_OUTPUT_SKIP_NULLS)

#define SDQL2_IS_RUNNING (state == SDQL2_STATE_EXECUTING || state == SDQL2_STATE_SEARCHING || state == SDQL2_STATE_SWITCHING || state == SDQL2_STATE_PRESEARCH)
#define SDQL2_HALT_CHECK if(!SDQL2_IS_RUNNING) {state = SDQL2_STATE_HALTING; return FALSE;};

#define SDQL2_TICK_CHECK ((options & SDQL2_OPTION_HIGH_PRIORITY)? CHECK_TICK_HIGH_PRIORITY : CHECK_TICK)

#define SDQL2_STAGE_SWITCH_CHECK if(state != SDQL2_STATE_SWITCHING){\
		if(state == SDQL2_STATE_HALTING){\
			state = SDQL2_STATE_IDLE;\
			return FALSE}\
		state = SDQL2_STATE_ERROR;\
		CRASH("SDQL2 fatal error");};

/client/proc/SDQL2_query()
	set category = "Debug"

	if(!check_rights(R_PROCCALL))  //Shouldn't happen... but just to be safe.
		message_admins("<span class='danger'>ERROR: Non-admin [key_name_admin(usr)] attempted to execute a SDQL query!</span>")
		log_admin("Non-admin [key_name(usr)] attempted to execute a SDQL query!")
		return FALSE

	var/query_text = input("SDQL2 query") as message

	if(!query_text || length(query_text) < 1)
		return

	var/list/results = world.SDQL2_query(query_text, key_name_admin(usr), "[key_name(usr)]")
	if(length(results) == 3)
		for(var/I in 1 to 3)
			to_chat(usr, results[I])

/world/proc/SDQL2_query(query_text, log_entry1, log_entry2)
	var/query_log = "executed SDQL query(s): \"[query_text]\"."
	message_admins("[log_entry1] [query_log]")
	query_log = "[log_entry2] [query_log]"
	log_admin(query_log)

	var/start_time_total = REALTIMEOFDAY
	var/sequential = FALSE

	if(!length(query_text))
		return
	var/list/query_list = SDQL2_tokenize(query_text)
	if(!length(query_list))
		return
	var/list/querys = SDQL_parse(query_list)
	if(!length(querys))
		return
	var/list/datum/SDQL2_query/running = list()
	var/list/datum/SDQL2_query/waiting_queue = list() //Sequential queries queue.

	for(var/list/query_tree in querys)
		var/datum/SDQL2_query/query = new /datum/SDQL2_query(query_tree)
		if(QDELETED(query))
			continue
		if(usr)
			query.show_next_to_key = usr.ckey
		waiting_queue += query
		if(query.options & SDQL2_OPTION_SEQUENTIAL)
			sequential = TRUE

	if(sequential) //Start first one
		var/datum/SDQL2_query/query = popleft(waiting_queue)
		running += query
		var/msg = "Starting query #[query.id] - [query.get_query_text()]."
		if(usr)
			to_chat(usr, "<span class='admin'>[msg]</span>")
		log_admin(msg)
		query.ARun()
	else //Start all
		for(var/datum/SDQL2_query/query in waiting_queue)
			running += query
			var/msg = "Starting query #[query.id] - [query.get_query_text()]."
			if(usr)
				to_chat(usr, "<span class='admin'>[msg]</span>")
			log_admin(msg)
			query.ARun()

	var/finished = FALSE
	var/objs_all = 0
	var/objs_eligible = 0
	var/selectors_used = FALSE
	var/list/combined_refs = list()
	do
		CHECK_TICK
		finished = TRUE
		for(var/i in running)
			var/datum/SDQL2_query/query = i
			if(QDELETED(query))
				running -= query
				continue
			else if(query.state != SDQL2_STATE_IDLE)
				finished = FALSE
				if(query.state == SDQL2_STATE_ERROR)
					if(usr)
						to_chat(usr, "<span class='admin'>SDQL query [query.get_query_text()] errored. It will NOT be automatically garbage collected. Please remove manually.</span>")
					running -= query
			else
				if(query.finished)
					objs_all += islist(query.obj_count_all)? length(query.obj_count_all) : query.obj_count_all
					objs_eligible += islist(query.obj_count_eligible)? length(query.obj_count_eligible) : query.obj_count_eligible
					selectors_used |= query.where_switched
					combined_refs |= query.select_refs
					running -= query
					if(!CHECK_BITFIELD(query.options, SDQL2_OPTION_DO_NOT_AUTOGC))
						QDEL_IN(query, 50)
					if(sequential && waiting_queue.len)
						finished = FALSE
						var/datum/SDQL2_query/next_query = popleft(waiting_queue)
						running += next_query
						var/msg = "Starting query #[next_query.id] - [next_query.get_query_text()]."
						if(usr)
							to_chat(usr, "<span class='admin'>[msg]</span>")
						log_admin(msg)
						next_query.ARun()
				else
					if(usr)
						to_chat(usr, "<span class='admin'>SDQL query [query.get_query_text()] was halted. It will NOT be automatically garbage collected. Please remove manually.</span>")
					running -= query
	while(!finished)

	var/end_time_total = REALTIMEOFDAY - start_time_total
	return list("<span class='admin'>SDQL query combined results: [query_text]</span>",\
		"<span class='admin'>SDQL query completed: [objs_all] objects selected by path, and [selectors_used ? objs_eligible : objs_all] objects executed on after WHERE filtering/MAPping if applicable.</span>",\
		"<span class='admin'>SDQL combined querys took [DisplayTimeText(end_time_total)] to complete.</span>") + combined_refs

GLOBAL_LIST_INIT(sdql2_queries, GLOB.sdql2_queries || list())
GLOBAL_DATUM_INIT(sdql2_vv_statobj, /obj/effect/statclick/SDQL2_VV_all, new(null, "VIEW VARIABLES (all)", null))

/datum/SDQL2_query
	var/list/query_tree
	var/state = SDQL2_STATE_IDLE
	var/options = SDQL2_OPTIONS_DEFAULT
	var/superuser = FALSE		//Run things like proccalls without using admin protections
	var/allow_admin_interact = TRUE		//Allow admins to do things to this excluding varedit these two vars
	var/static/id_assign = 1
	var/id = 0

	var/qdel_on_finish = FALSE

	//Last run
		//General
	var/finished = FALSE
	var/start_time
	var/end_time
	var/where_switched = FALSE
	var/show_next_to_key
		//Select query only
	var/list/select_refs
	var/list/select_text
		//Runtime tracked
			//These three are weird. For best performance, they are only a number when they're not being changed by the SDQL searching/execution code. They only become numbers when they finish changing.
	var/list/obj_count_all
	var/list/obj_count_eligible
	var/list/obj_count_finished

	//Statclick
	var/obj/effect/statclick/SDQL2_delete/delete_click
	var/obj/effect/statclick/SDQL2_action/action_click

/datum/SDQL2_query/New(list/tree, SU = FALSE, admin_interact = TRUE, _options = SDQL2_OPTIONS_DEFAULT, finished_qdel = FALSE)
	if(!LAZYLEN(tree))
		qdel(src)
		return
	LAZYADD(GLOB.sdql2_queries, src)
	superuser = SU
	allow_admin_interact = admin_interact
	query_tree = tree
	options = _options
	id = id_assign++
	qdel_on_finish = finished_qdel

/datum/SDQL2_query/Destroy()
	state = SDQL2_STATE_HALTING
	query_tree = null
	obj_count_all = null
	obj_count_eligible = null
	obj_count_finished = null
	select_text = null
	select_refs = null
	GLOB.sdql2_queries -= src
	return ..()

/datum/SDQL2_query/proc/get_query_text()
	var/list/out = list()
	recursive_list_print(out, query_tree)
	return out.Join()

/proc/recursive_list_print(list/output = list(), list/input, datum/callback/datum_handler, datum/callback/atom_handler)
	output += "\[ "
	for(var/i in 1 to input.len)
		var/final = i == input.len
		var/key = input[i]

		//print the key
		if(islist(key))
			recursive_list_print(output, key, datum_handler, atom_handler)
		else if(is_proper_datum(key) && (datum_handler || (isatom(key) && atom_handler)))
			if(isatom(key) && atom_handler)
				output += atom_handler.Invoke(key)
			else
				output += datum_handler.Invoke(key)
		else
			output += "[key]"

		//print the value
		var/is_value = (!isnum(key) && !isnull(input[key]))
		if(is_value)
			var/value = input[key]
			if(islist(value))
				recursive_list_print(output, value, datum_handler, atom_handler)
			else if(is_proper_datum(value) && (datum_handler || (isatom(value) && atom_handler)))
				if(isatom(value) && atom_handler)
					output += atom_handler.Invoke(value)
				else
					output += datum_handler.Invoke(value)
			else
				output += " = [value]"

		if(!final)
			output += " , "

	output += " \]"

/datum/SDQL2_query/proc/text_state()
	switch(state)
		if(SDQL2_STATE_ERROR)
			return "###ERROR"
		if(SDQL2_STATE_IDLE)
			return "####IDLE"
		if(SDQL2_STATE_PRESEARCH)
			return "PRESEARCH"
		if(SDQL2_STATE_SEARCHING)
			return "SEARCHING"
		if(SDQL2_STATE_EXECUTING)
			return "EXECUTING"
		if(SDQL2_STATE_SWITCHING)
			return "SWITCHING"
		if(SDQL2_STATE_HALTING)
			return "##HALTING"

/datum/SDQL2_query/proc/generate_stat()
	if(!allow_admin_interact)
		return
	if(!delete_click)
		delete_click = new(null, "INITIALIZING", src)
	if(!action_click)
		action_click = new(null, "INITIALIZNG", src)
	stat("[id]		", delete_click.update("DELETE QUERY | STATE : [text_state()] | ALL/ELIG/FIN \
	[islist(obj_count_all)? length(obj_count_all) : (isnull(obj_count_all)? "0" : obj_count_all)]/\
	[islist(obj_count_eligible)? length(obj_count_eligible) : (isnull(obj_count_eligible)? "0" : obj_count_eligible)]/\
	[islist(obj_count_finished)? length(obj_count_finished) : (isnull(obj_count_finished)? "0" : obj_count_finished)] - [get_query_text()]"))
	stat("			", action_click.update("[SDQL2_IS_RUNNING? "HALT" : "RUN"]"))

/datum/SDQL2_query/proc/delete_click()
	admin_del(usr)

/datum/SDQL2_query/proc/action_click()
	if(SDQL2_IS_RUNNING)
		admin_halt(usr)
	else
		admin_run(usr)

/datum/SDQL2_query/proc/admin_halt(user = usr)
	if(!SDQL2_IS_RUNNING)
		return
	var/msg = "[key_name(user)] has halted query #[id]"
	message_admins(msg)
	log_admin(msg)
	state = SDQL2_STATE_HALTING

/datum/SDQL2_query/proc/admin_run(mob/user = usr)
	if(SDQL2_IS_RUNNING)
		return
	var/msg = "[key_name(user)] has (re)started query #[id]"
	message_admins(msg)
	log_admin(msg)
	show_next_to_key = user.ckey
	ARun()

/datum/SDQL2_query/proc/admin_del(user = usr)
	var/msg = "[key_name(user)] has stopped + deleted query #[id]"
	message_admins(msg)
	log_admin(msg)
	qdel(src)

/datum/SDQL2_query/proc/set_option(name, value)
	switch(name)
		if("select")
			switch(value)
				if("force_nulls")
					DISABLE_BITFIELD(options, SDQL2_OPTION_SELECT_OUTPUT_SKIP_NULLS)
		if("proccall")
			switch(value)
				if("blocking")
					ENABLE_BITFIELD(options, SDQL2_OPTION_BLOCKING_CALLS)
		if("priority")
			switch(value)
				if("high")
					ENABLE_BITFIELD(options, SDQL2_OPTION_HIGH_PRIORITY)
		if("autogc")
			switch(value)
				if("keep_alive")
					ENABLE_BITFIELD(options, SDQL2_OPTION_DO_NOT_AUTOGC)
		if("sequential")
			switch(value)
				if("true")
					ENABLE_BITFIELD(options,SDQL2_OPTION_SEQUENTIAL)

/datum/SDQL2_query/proc/ARun()
	INVOKE_ASYNC(src, .proc/Run)

/datum/SDQL2_query/proc/Run()
	if(SDQL2_IS_RUNNING)
		return FALSE
	if(query_tree["options"])
		for(var/name in query_tree["options"])
			var/value = query_tree["options"][name]
			set_option(name, value)
	select_refs = list()
	select_text = null
	obj_count_all = 0
	obj_count_eligible = 0
	obj_count_finished = 0
	start_time = REALTIMEOFDAY

	state = SDQL2_STATE_PRESEARCH
	var/list/search_tree = PreSearch()
	SDQL2_STAGE_SWITCH_CHECK

	state = SDQL2_STATE_SEARCHING
	var/list/found = Search(search_tree)
	SDQL2_STAGE_SWITCH_CHECK

	state = SDQL2_STATE_EXECUTING
	Execute(found)
	SDQL2_STAGE_SWITCH_CHECK

	end_time = REALTIMEOFDAY
	state = SDQL2_STATE_IDLE
	finished = TRUE
	. = TRUE
	if(show_next_to_key)
		var/client/C = GLOB.directory[show_next_to_key]
		if(C)
			var/mob/showmob = C.mob
			to_chat(showmob, "<span class='admin'>SDQL query results: [get_query_text()]<br>\
			SDQL query completed: [islist(obj_count_all)? length(obj_count_all) : obj_count_all] objects selected by path, and \
			[where_switched? "[islist(obj_count_eligible)? length(obj_count_eligible) : obj_count_eligible] objects executed on after WHERE keyword selection." : ""]<br>\
			SDQL query took [DisplayTimeText(end_time - start_time)] to complete.</span>")
			if(length(select_text))
				var/text = islist(select_text)? select_text.Join() : select_text
				var/static/result_offset = 0
				showmob << browse(text, "window=SDQL-result-[result_offset++]")
	show_next_to_key = null
	if(qdel_on_finish)
		qdel(src)

/datum/SDQL2_query/proc/PreSearch()
	SDQL2_HALT_CHECK
	switch(query_tree[1])
		if("explain")
			SDQL_testout(query_tree["explain"])
			state = SDQL2_STATE_HALTING
			return
		if("call")
			. = query_tree["on"]
		if("select", "delete", "update")
			. = query_tree[query_tree[1]]
	state = SDQL2_STATE_SWITCHING

/datum/SDQL2_query/proc/Search(list/tree)
	SDQL2_HALT_CHECK
	var/type = tree[1]
	var/list/from = tree[2]
	var/list/objs = SDQL_from_objs(from)
	SDQL2_TICK_CHECK
	SDQL2_HALT_CHECK
	objs = SDQL_get_all(type, objs)
	SDQL2_TICK_CHECK
	SDQL2_HALT_CHECK

	// 1 and 2 are type and FROM.
	var/i = 3
	while (i <= tree.len)
		var/key = tree[i++]
		var/list/expression = tree[i++]
		switch (key)
			if ("map")
				for(var/j = 1 to objs.len)
					var/x = objs[j]
					objs[j] = SDQL_expression(x, expression)
					SDQL2_TICK_CHECK
					SDQL2_HALT_CHECK

			if ("where")
				where_switched = TRUE
				var/list/out = list()
				obj_count_eligible = out
				for(var/x in objs)
					if(SDQL_expression(x, expression))
						out += x
					SDQL2_TICK_CHECK
					SDQL2_HALT_CHECK
				objs = out
	if(islist(obj_count_eligible))
		obj_count_eligible = objs.len
	else
		obj_count_eligible = obj_count_all
	. = objs
	state = SDQL2_STATE_SWITCHING

/datum/SDQL2_query/proc/SDQL_from_objs(list/tree)
	if("world" in tree)
		return world
	return SDQL_expression(world, tree)

/datum/SDQL2_query/proc/SDQL_get_all(type, location)
	var/list/out = list()
	obj_count_all = out

// If only a single object got returned, wrap it into a list so the for loops run on it.
	if(!islist(location) && location != world)
		location = list(location)

	if(type == "*")
		for(var/i in location)
			var/datum/d = i
			if((d && d.can_vv_get()) || superuser)
				out += d
			SDQL2_TICK_CHECK
			SDQL2_HALT_CHECK
		return out

	if(istext(type))
		type = text2path(type)
	var/typecache = typecacheof(type)

	if(ispath(type, /mob))
		for(var/mob/d in location)
			if(typecache[d.type] && (d.can_vv_get() || superuser))
				out += d
			SDQL2_TICK_CHECK
			SDQL2_HALT_CHECK

	else if(ispath(type, /turf))
		for(var/turf/d in location)
			if(typecache[d.type] && (d.can_vv_get() || superuser))
				out += d
			SDQL2_TICK_CHECK
			SDQL2_HALT_CHECK

	else if(ispath(type, /obj))
		for(var/obj/d in location)
			if(typecache[d.type] && (d.can_vv_get() || superuser))
				out += d
			SDQL2_TICK_CHECK
			SDQL2_HALT_CHECK

	else if(ispath(type, /area))
		for(var/area/d in location)
			if(typecache[d.type] && (d.can_vv_get() || superuser))
				out += d
			SDQL2_TICK_CHECK
			SDQL2_HALT_CHECK

	else if(ispath(type, /atom))
		for(var/atom/d in location)
			if(typecache[d.type] && (d.can_vv_get() || superuser))
				out += d
			SDQL2_TICK_CHECK
			SDQL2_HALT_CHECK

	else if(ispath(type, /datum))
		if(location == world) //snowflake for byond shortcut
			for(var/datum/d) //stupid byond trick to have it not return atoms to make this less laggy
				if(typecache[d.type] && (d.can_vv_get() || superuser))
					out += d
				SDQL2_TICK_CHECK
				SDQL2_HALT_CHECK
		else
			for(var/datum/d in location)
				if(typecache[d.type] && (d.can_vv_get() || superuser))
					out += d
				SDQL2_TICK_CHECK
				SDQL2_HALT_CHECK
	obj_count_all = out.len
	return out

/datum/SDQL2_query/proc/Execute(list/found)
	SDQL2_HALT_CHECK
	select_refs = list()
	select_text = list()
	switch(query_tree[1])
		if("call")
			for(var/i in found)
				if(!is_proper_datum(i))
					continue
				world.SDQL_var(i, query_tree["call"][1], null, i, superuser, src)
				obj_count_finished++
				SDQL2_TICK_CHECK
				SDQL2_HALT_CHECK

		if("delete")
			for(var/datum/d in found)
				SDQL_qdel_datum(d)
				obj_count_finished++
				SDQL2_TICK_CHECK
				SDQL2_HALT_CHECK

		if("select")
			var/list/text_list = list()
			var/print_nulls = !(options & SDQL2_OPTION_SELECT_OUTPUT_SKIP_NULLS)
			obj_count_finished = select_refs
			for(var/i in found)
				SDQL_print(i, text_list, print_nulls)
				if(is_proper_datum(i))
					var/datum/I = i
					select_refs[I.UID()] = TRUE
				else
					select_refs["\ref[i]"] = TRUE
				SDQL2_TICK_CHECK
				SDQL2_HALT_CHECK
			select_text = text_list

		if("update")
			if("set" in query_tree)
				var/list/set_list = query_tree["set"]
				for(var/d in found)
					if(!is_proper_datum(d))
						continue
					SDQL_internal_vv(d, set_list)
					obj_count_finished++
					SDQL2_TICK_CHECK
					SDQL2_HALT_CHECK
	if(islist(obj_count_finished))
		obj_count_finished = obj_count_finished.len
	state = SDQL2_STATE_SWITCHING

/datum/SDQL2_query/proc/SDQL_print(object, list/text_list, print_nulls = TRUE)
	if(is_proper_datum(object))
		var/datum/O = object
		text_list += "<A HREF='?_src_=vars;Vars=[O.UID()]'>\ref[O]</A> : [object]"
		if(istype(object, /atom))
			var/atom/A = object
			var/turf/T = A.loc
			var/area/a
			if(istype(T))
				text_list += " <font color='gray'>at</font> [T] [ADMIN_COORDJMP(T)]"
				a = T.loc
			else
				var/turf/final = get_turf(T)		//Recursive, hopefully?
				if(istype(final))
					text_list += " <font color='gray'>at</font> [final] [ADMIN_COORDJMP(final)]"
					a = final.loc
				else
					text_list += " <font color='gray'>at</font> nonexistant location"
			if(a)
				text_list += " <font color='gray'>in</font> area [a]"
				if(T.loc != a)
					text_list += " <font color='gray'>inside</font> [T]"
		text_list += "<br>"
	else if(islist(object))
		var/list/L = object
		var/first = TRUE
		text_list += "\["
		for (var/x in L)
			if (!first)
				text_list += ", "
			first = FALSE
			SDQL_print(x, text_list)
			if (!isnull(x) && !isnum(x) && L[x] != null)
				text_list += " -> "
				SDQL_print(L[L[x]])
		text_list += "]<br>"
	else
		if(isnull(object))
			if(print_nulls)
				text_list += "NULL<br>"
		else
			text_list += "[object]<br>"

/datum/SDQL2_query/vv_edit_var(var_name, var_value)
	if(!allow_admin_interact)
		return FALSE
	if(var_name == NAMEOF(src, superuser) || var_name == NAMEOF(src, allow_admin_interact) || var_name == NAMEOF(src, query_tree))
		return FALSE
	return ..()

/datum/SDQL2_query/proc/SDQL_internal_vv(d, list/set_list)
	for(var/list/sets in set_list)
		var/datum/temp = d
		var/i = 0
		for(var/v in sets)
			if(++i == sets.len)
				if(superuser)
					if(temp.vars.Find(v))
						temp.vars[v] = SDQL_expression(d, set_list[sets])
				else
					temp.vv_edit_var(v, SDQL_expression(d, set_list[sets]))
				break
			if(temp.vars.Find(v) && (istype(temp.vars[v], /datum) || istype(temp.vars[v], /client)))
				temp = temp.vars[v]
			else
				break

/datum/SDQL2_query/proc/SDQL_function_blocking(datum/object, procname, list/arguments, source)
	var/list/new_args = list()
	for(var/arg in arguments)
		new_args[++new_args.len] = SDQL_expression(source, arg)
	if(object == GLOB) // Global proc.
		procname = "/proc/[procname]"
		return (call(procname)(new_args))
	return (call(object, procname)(new_args))

/datum/SDQL2_query/proc/SDQL_function_async(datum/object, procname, list/arguments, source)
	set waitfor = FALSE
	return SDQL_function_blocking(object, procname, arguments, source)

/datum/SDQL2_query/proc/SDQL_expression(datum/object, list/expression, start = 1)
	var/result = 0
	var/val

	for(var/i = start, i <= expression.len, i++)
		var/op = ""

		if(i > start)
			op = expression[i]
			i++

		var/list/ret = SDQL_value(object, expression, i)
		val = ret["val"]
		i = ret["i"]

		if(op != "")
			switch(op)
				if("+")
					result = (result + val)
				if("-")
					result = (result - val)
				if("*")
					result = (result * val)
				if("/")
					result = (result / val)
				if("&")
					result = (result & val)
				if("|")
					result = (result | val)
				if("^")
					result = (result ^ val)
				if("%")
					result = (result % val)
				if("=", "==")
					result = (result == val)
				if("!=", "<>")
					result = (result != val)
				if("<")
					result = (result < val)
				if("<=")
					result = (result <= val)
				if(">")
					result = (result > val)
				if(">=")
					result = (result >= val)
				if("and", "&&")
					result = (result && val)
				if("or", "||")
					result = (result || val)
				else
					to_chat(usr, "<span class='danger'>SDQL2: Unknown op [op]</span>")
					result = null
		else
			result = val

	return result

/datum/SDQL2_query/proc/SDQL_value(datum/object, list/expression, start = 1)
	var/i = start
	var/val = null

	if(i > expression.len)
		return list("val" = null, "i" = i)

	if(istype(expression[i], /list))
		val = SDQL_expression(object, expression[i])

	else if(expression[i] == "TRUE")
		val = TRUE

	else if(expression[i] == "FALSE")
		val = FALSE

	else if(expression[i] == "!")
		var/list/ret = SDQL_value(object, expression, i + 1)
		val = !ret["val"]
		i = ret["i"]

	else if(expression[i] == "~")
		var/list/ret = SDQL_value(object, expression, i + 1)
		val = ~ret["val"]
		i = ret["i"]

	else if(expression[i] == "-")
		var/list/ret = SDQL_value(object, expression, i + 1)
		val = -ret["val"]
		i = ret["i"]

	else if(expression[i] == "null")
		val = null

	else if(isnum(expression[i]))
		val = expression[i]

	else if(ispath(expression[i]))
		val = expression[i]

	else if(copytext(expression[i], 1, 2) in list("'", "\""))
		val = copytext(expression[i], 2, length(expression[i]))

	else if(expression[i] == "\[")
		var/list/expressions_list = expression[++i]
		val = list()
		for(var/list/expression_list in expressions_list)
			var/result = SDQL_expression(object, expression_list)
			var/assoc
			if(expressions_list[expression_list] != null)
				assoc = SDQL_expression(object, expressions_list[expression_list])
			if(assoc != null)
				// Need to insert the key like this to prevent duplicate keys fucking up.
				var/list/dummy = list()
				dummy[result] = assoc
				result = dummy
			val += result

	else if(expression[i] == "@\[")
		var/list/search_tree = expression[++i]
		var/already_searching = (state == SDQL2_STATE_SEARCHING) //In case we nest, don't want to break out of the searching state until we're all done.

		if(!already_searching)
			state = SDQL2_STATE_SEARCHING

		val = Search(search_tree)
		SDQL2_STAGE_SWITCH_CHECK

		if(!already_searching)
			state = SDQL2_STATE_EXECUTING
		else
			state = SDQL2_STATE_SEARCHING

	else
		val = world.SDQL_var(object, expression, i, object, superuser, src)
		i = expression.len

	return list("val" = val, "i" = i)

/proc/SDQL_parse(list/query_list)
	var/datum/SDQL_parser/parser = new()
	var/list/querys = list()
	var/list/query_tree = list()
	var/pos = 1
	var/querys_pos = 1
	var/do_parse = 0

	for(var/val in query_list)
		if(val == ";")
			do_parse = 1
		else if(pos >= query_list.len)
			query_tree += val
			do_parse = 1

		if(do_parse)
			parser.query = query_tree
			var/list/parsed_tree
			parsed_tree = parser.parse()
			if(parsed_tree.len > 0)
				querys.len = querys_pos
				querys[querys_pos] = parsed_tree
				querys_pos++
			else //There was an error so don't run anything, and tell the user which query has errored.
				to_chat(usr, "<span class='danger'>Parsing error on [querys_pos]\th query. Nothing was executed.</span>")
				return list()
			query_tree = list()
			do_parse = 0
		else
			query_tree += val
		pos++

	qdel(parser)
	return querys

/proc/SDQL_testout(list/query_tree, indent = 0)
	var/static/whitespace = "&nbsp;&nbsp;&nbsp; "
	var/spaces = ""
	for(var/s = 0, s < indent, s++)
		spaces += whitespace

	for(var/item in query_tree)
		if(istype(item, /list))
			to_chat(usr, "[spaces](")
			SDQL_testout(item, indent + 1)
			to_chat(usr, "[spaces])")

		else
			to_chat(usr, "[spaces][item]")

		if(!isnum(item) && query_tree[item])

			if(istype(query_tree[item], /list))
				to_chat(usr, "[spaces][whitespace](")
				SDQL_testout(query_tree[item], indent + 2)
				to_chat(usr, "[spaces][whitespace])")

			else
				to_chat(usr, "[spaces][whitespace][query_tree[item]]")

// Was a world proc on tg for perf reasons
/world/proc/SDQL_var(object, list/expression, start = 1, source, superuser, datum/SDQL2_query/query)
	var/v
	var/static/list/exclude = list("usr", "src", "marked", "global")
	var/long = start < expression.len
	var/datum/D
	if(is_proper_datum(object))
		D = object

	if (object == world && (!long || expression[start + 1] == ".") && !(expression[start] in exclude))
		to_chat(usr, "<span class='danger'>World variables are not allowed to be accessed. Use global.</span>")
		return null

	else if(expression [start] == "{" && long)
		if(lowertext(copytext(expression[start + 1], 1, 3)) != "0x")
			to_chat(usr, "<span class='danger'>Invalid pointer syntax: [expression[start + 1]]</span>")
			return null
		v = locate("\[[expression[start + 1]]]")
		if(!v)
			to_chat(usr, "<span class='danger'>Invalid pointer: [expression[start + 1]]</span>")
			return null
		start++
		long = start < expression.len
	else if(expression[start] == "(" && long)
		v = query.SDQL_expression(source, expression[start + 1])
		start++
		long = start < expression.len
	else if(D != null && (!long || expression[start + 1] == ".") && (expression[start] in D.vars))
		if(D.can_vv_get(expression[start]) || superuser)
			v = D.vars[expression[start]]
		else
			v = "SECRET"
	else if(D != null && long && expression[start + 1] == ":" && hascall(D, expression[start]))
		v = expression[start]
	else if(!long || expression[start + 1] == ".")
		switch(expression[start])
			if("usr")
				v = usr
			if("src")
				v = source
			if("marked")
				if(usr.client && usr.client.holder && usr.client.holder.marked_datum)
					v = usr.client.holder.marked_datum
				else
					return null
			if("world")
				v = world
			if("global")
				v = GLOB
			if("MC")
				v = Master
			if("FS")
				v = Failsafe
			if("CFG")
				v = config
			//Subsystem switches
			if("SSgarbage")
				v = SSgarbage
			if("SSmachines")
				v = SSmachines
			if("SSobj")
				v = SSobj
			if("SSfastprocess")
				v = SSfastprocess
			if("SSticker")
				v = SSticker
			if("SStimer")
				v = SStimer
			if("SSnpcpool")
				v = SSnpcpool
			if("SSmobs")
				v = SSmobs
			if("SSshuttle")
				v = SSshuttle
			if("SSmapping")
				v = SSmapping
			if("SSevents")
				v = SSevents
			if("SSchat")
				v = SSchat
			if("SSjobs")
				v = SSjobs
			if("SSparallax")
				v = SSparallax
			//End
			else
				return null
	else if(object == GLOB) // Shitty ass hack kill me.
		v = expression[start]
	if(long)
		if(expression[start + 1] == ".")
			return SDQL_var(v, expression[start + 2], null, source, superuser, query)
		else if(expression[start + 1] == ":")
			return (query.options & SDQL2_OPTION_BLOCKING_CALLS)? query.SDQL_function_async(object, v, expression[start + 2], source) : query.SDQL_function_blocking(object, v, expression[start + 2], source)
		else if(expression[start + 1] == "\[" && islist(v))
			var/list/L = v
			var/index = query.SDQL_expression(source, expression[start + 2])
			if(isnum(index) && (!IsInteger(index) || L.len < index))
				to_chat(usr, "<span class='danger'>Invalid list index: [index]</span>")
				return null
			return L[index]
	return v

/proc/SDQL2_tokenize(query_text)

	var/list/whitespace = list(" ", "\n", "\t")
	var/list/single = list("(", ")", ",", "+", "-", ".", "\[", "]", "{", "}", ";", ":")
	var/list/multi = list(
					"=" = list("", "="),
					"<" = list("", "=", ">"),
					">" = list("", "="),
					"!" = list("", "="),
					"@" = list("\["))

	var/word = ""
	var/list/query_list = list()
	var/len = length(query_text)

	for(var/i = 1, i <= len, i++)
		var/char = copytext(query_text, i, i + 1)

		if(char in whitespace)
			if(word != "")
				query_list += word
				word = ""

		else if(char in single)
			if(word != "")
				query_list += word
				word = ""

			query_list += char

		else if(char in multi)
			if(word != "")
				query_list += word
				word = ""

			var/char2 = copytext(query_text, i + 1, i + 2)

			if(char2 in multi[char])
				query_list += "[char][char2]"
				i++

			else
				query_list += char

		else if(char == "'")
			if(word != "")
				to_chat(usr, "<span class='danger'>SDQL2: You have an error in your SDQL syntax, unexpected ' in query: \"<font color=gray>[query_text]</font>\" following \"<font color=gray>[word]</font>\". Please check your syntax, and try again.</span>")
				return null

			word = "'"

			for(i++, i <= len, i++)
				char = copytext(query_text, i, i + 1)

				if(char == "'")
					if(copytext(query_text, i + 1, i + 2) == "'")
						word += "'"
						i++

					else
						break

				else
					word += char

			if(i > len)
				to_chat(usr, "<span class='danger'>SDQL2: You have an error in your SDQL syntax, unmatched ' in query: \"<font color=gray>[query_text]</font>\". Please check your syntax, and try again.</span>")
				return null

			query_list += "[word]'"
			word = ""

		else if(char == "\"")
			if(word != "")
				to_chat(usr, "<span class='danger'>SDQL2: You have an error in your SDQL syntax, unexpected \" in query: \"<font color=gray>[query_text]</font>\" following \"<font color=gray>[word]</font>\". Please check your syntax, and try again.</span>")
				return null

			word = "\""

			for(i++, i <= len, i++)
				char = copytext(query_text, i, i + 1)

				if(char == "\"")
					if(copytext(query_text, i + 1, i + 2) == "'")
						word += "\""
						i++

					else
						break

				else
					word += char

			if(i > len)
				to_chat(usr, "<span class='danger'>SDQL2: You have an error in your SDQL syntax, unmatched \" in query: \"<font color=gray>[query_text]</font>\". Please check your syntax, and try again.</span>")
				return null

			query_list += "[word]\""
			word = ""

		else
			word += char

	if(word != "")
		query_list += word
	return query_list

/proc/is_proper_datum(thing)
	return istype(thing, /datum) || istype(thing, /client)

/obj/effect/statclick/SDQL2_delete/Click()
	var/datum/SDQL2_query/Q = target
	Q.delete_click()

/obj/effect/statclick/SDQL2_action/Click()
	var/datum/SDQL2_query/Q = target
	Q.action_click()

/obj/effect/statclick/SDQL2_VV_all
	name = "VIEW VARIABLES"

/obj/effect/statclick/SDQL2_VV_all/Click()
	usr.client.debug_variables(GLOB.sdql2_queries)
