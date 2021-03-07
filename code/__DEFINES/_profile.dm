// This file exists so that world.Profile() is THE FIRST PROC TO RUN in the init sequence. This allows us to get the real details of everything lagging at server start.
// We don't actually care about storing the output here, this is just an easy way to ensure the profile runs first.
GLOBAL_REAL_VAR(world_init_profiler) = world.Profile(PROFILE_START)
