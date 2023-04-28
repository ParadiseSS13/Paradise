#define DMJIT_LIB "./libdmjit.so"
#define DMJIT_NATIVE CRASH("dm-jit not loaded")

/proc/dmjit_hook_main_init()
	if (world.system_type != UNIX)
		return
	world.log << CALL_EXT(DMJIT_LIB, "auxtools_init")()
	world.log << dmjit_hook_log_init()
	dmjit_compile_proc("/datum/gas_mixture/temperature_share")
	dmjit_compile_proc("/datum/gas_mixture/heat_capacity")
	dmjit_compile_proc("/datum/gas_mixture/total_moles")
	dmjit_compile_proc("/datum/gas_mixture/share")
	dmjit_compile_proc("/datum/gas_mixture/archive")
	dmjit_compile_proc("/datum/gas_mixture/compare")
	dmjit_compile_proc("/datum/gas_mixture/heat_capacity_archived")
	dmjit_compile_proc("/turf/simulated/share_air")
	//dmjit_compile_proc("/turf/simulated/archive") uses global
	world.log << dmjit_install_compiled()


// INIT
/proc/dmjit_hook_log_init()
	DMJIT_NATIVE

// DEBUG
/proc/dmjit_hook_call(src)
	DMJIT_NATIVE

// DEBUG Re-enter
/proc/dmjit_on_test_call()
	DMJIT_NATIVE

// Dump call counts
/proc/dmjit_dump_call_count()
	DMJIT_NATIVE

// Dump opcode use counts
/proc/dmjit_dump_opcode_count()
	DMJIT_NATIVE

/proc/dmjit_dump_opcodes(name)
	DMJIT_NATIVE

/proc/dmjit_hook_compile()
	DMJIT_NATIVE

/proc/auxtools_stack_trace(msg)
	CRASH(msg)

/proc/dmjit_compile_proc(name)
    DMJIT_NATIVE

/proc/dmjit_install_compiled()
    DMJIT_NATIVE

/proc/dmjit_toggle_hooks()
    DMJIT_NATIVE

/proc/dmjit_toggle_call_counts()
    DMJIT_NATIVE

/proc/dmjit_get_datum_ref_count(arg)
    DMJIT_NATIVE

/proc/dmjit_mark_time(name)
    DMJIT_NATIVE

/proc/dmjit_report_time(name)
    DMJIT_NATIVE

/proc/dmjit_call_hierarchy(name)
    DMJIT_NATIVE

/proc/dmjit_dump_deopts()
    DMJIT_NATIVE
