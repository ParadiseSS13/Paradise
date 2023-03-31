PROCESSING_SUBSYSTEM_DEF(projectiles)
	name = "Projectiles"
	wait = 1
	flags = SS_NO_INIT|SS_TICKER
	offline_implications = "Projectiles will no longer move. Shuttle call recommended."
	cpu_display = SS_CPUDISPLAY_HIGH

	/// Maximum moves a projectile can make per tick.
	var/global_max_tick_moves = 10
	/// How many pixels one iteration can move a projectile.
	var/global_pixel_speed = 2
	/// Maximum iterations a move can perform.
	var/global_iterations_per_move = 16
