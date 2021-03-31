/atom/movable/key_loop(client/C)
	if(!C.input_data)
		return

	var/direction = C.input_data.compute_actual_move_dir()
	C.Move(get_step(src, direction), direction)
