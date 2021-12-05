/client/proc/dmjit_debug_toggle_hooks()
	set category = "Debug"
	set name = "dmJIT toggle hooks"

	if(!check_rights(R_DEBUG))
		return

	var/result = dmjit_toggle_hooks()

	message_admins("[key_name_admin(usr)] dmJIT Hooks state is [result]")


/client/proc/dmjit_debug_toggle_call_counts()
	set category = "Debug"
	set name = "dmJIT toggle call count"

	if(!check_rights(R_DEBUG))
		return

	var/result = dmjit_toggle_call_counts()

	message_admins("[key_name_admin(usr)] dmJIT call count state is [result]")

/client/proc/dmjit_debug_dump_call_count()
	set category = "Debug"
	set name = "dmJIT dump call count"

	if(!check_rights(R_DEBUG))
		return

	dmjit_dump_call_count()
	message_admins("[key_name_admin(usr)] Performed dmJIT call count dump")

/client/proc/dmjit_debug_dump_opcode_count()
	set category = "Debug"
	set name = "dmJIT dump opcode count"

	if(!check_rights(R_DEBUG))
		return

	dmjit_dump_opcode_count()
	message_admins("[key_name_admin(usr)] Performed dmJIT opcode count dump")

/client/proc/dmjit_debug_dump_deopts()
	set category = "Debug"
	set name = "dmJIT dump deopts"

	if(!check_rights(R_DEBUG))
		return

	dmjit_dump_deopts()
	message_admins("[key_name_admin(usr)] Performed dmJIT deopt count dump")
