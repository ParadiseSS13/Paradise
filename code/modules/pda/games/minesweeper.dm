// Minesweeper

#define MINESWEEPER_ROWS 16
#define MINESWEEPER_COLUMNS 16
#define MINESWEEPER_BOMBS 40

/datum/data/pda/app/game/minesweeper
	name = "Minesweeper"
	template = "pda_minesweeper"
	update = PDA_APP_NOUPDATE

	/// Thing, to make first touch safety
	var/first_touch = TRUE
	// Win condition things
	var/setted_flags = 0
	var/flagged_bombs = 0
	var/opened_cells = 0
	/// Decision to make interface untouchable in the momemnt of regenerating
	var/ignore_touches = FALSE
	/// Here we have all the minesweeper info
	var/list/minesweeper_matrix = list()
	// generations vars
	var/generation_rows = MINESWEEPER_ROWS
	var/generation_columns = MINESWEEPER_COLUMNS
	var/generation_bombs = MINESWEEPER_BOMBS

	/// The moment then game was started for point count
	var/start_time = 0

	/// The leaderboard list
	var/static/list/leaderboard = list()

/datum/data/pda/app/game/minesweeper/start()
	. = ..()
	make_empty_matrix()

/datum/data/pda/app/game/minesweeper/update_ui(mob/user, list/data)
	data["matrix"] = minesweeper_matrix
	data["flags"] = setted_flags
	data["bombs"] = generation_bombs
	data["leaderboard"] = leaderboard

/datum/data/pda/app/game/minesweeper/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	if(ignore_touches)
		return

	switch(action)
		if("Square")
			switch(params["mode"])
				if("bomb")
					if(first_touch)
						generate_matrix(params["X"], params["Y"])
					open_cell(params["X"], params["Y"])

					if(minesweeper_matrix[params["X"]][params["Y"]]["bomb"])
						on_loose(ui.user)
						SStgui.update_uis(pda)
						return

				if("flag")
					if(first_touch || minesweeper_matrix[params["X"]][params["Y"]]["open"])
						return

					if(minesweeper_matrix[params["X"]][params["Y"]]["flag"])
						minesweeper_matrix[params["X"]][params["Y"]]["flag"] = FALSE
						setted_flags -= 1
						if(minesweeper_matrix[params["X"]][params["Y"]]["bomb"])
							flagged_bombs -= 1
					else
						minesweeper_matrix[params["X"]][params["Y"]]["flag"] = TRUE
						setted_flags += 1
						if(minesweeper_matrix[params["X"]][params["Y"]]["bomb"])
							flagged_bombs += 1

			check_win(ui.user)
			SStgui.update_uis(pda)

/datum/data/pda/app/game/minesweeper/proc/check_win(mob/user)
	if(flagged_bombs == generation_bombs && \
		setted_flags == generation_bombs && \
		opened_cells == (generation_rows * generation_columns - generation_bombs))
		on_win(user)

/datum/data/pda/app/game/minesweeper/proc/on_win(mob/user)
	ignore_touches = TRUE
	if(!pda.silent)
		playsound(get_turf(pda), 'sound/machines/ping.ogg', 20, TRUE)
	addtimer(CALLBACK(src, PROC_REF(make_empty_matrix)), 5 SECONDS)
	add_into_leaders(user, world.time - start_time)

/datum/data/pda/app/game/minesweeper/proc/add_into_leaders(mob/user, game_time)
	var/nickname = tgui_input_text(user, "You finished the game in [game_time / 10] seconds.\n Write a nickname to save your result on the leaderboard.\n", "Minesweeper", "", 10)
	if(!nickname)
		return

	leaderboard += list(list("name" = nickname, "time" = "[game_time/10]"))

/datum/data/pda/app/game/minesweeper/proc/on_loose(mob/user)
	ignore_touches = TRUE
	if(!pda.silent)
		playsound(get_turf(pda), 'sound/effects/explosionfar.ogg', 50, TRUE)
	addtimer(CALLBACK(src, PROC_REF(make_empty_matrix)), 3 SECONDS)

/datum/data/pda/app/game/minesweeper/proc/make_empty_matrix(pay = TRUE)
	minesweeper_matrix = list()
	for(var/i in 1 to generation_rows)
		var/list/new_row = list()
		for(var/j in 1 to generation_columns)
			new_row["[j]"] = list("open" = FALSE, "bomb" = FALSE, "flag" = FALSE, "around" = 0)
		minesweeper_matrix["[i]"] = new_row
	first_touch = TRUE
	ignore_touches = FALSE
	SStgui.update_uis(pda)

/datum/data/pda/app/game/minesweeper/proc/generate_matrix(x, y)
	flagged_bombs = 0
	setted_flags = 0
	opened_cells = 0
	var/list/possible_list = list()
	var/num_x = text2num(x)
	var/num_y = text2num(y)
	var/count = 0

	for(var/i in 1 to generation_rows)
		for(var/j in 1 to generation_columns)
			if((i in list(num_x - 1, num_x, num_x + 1)) && (j in list(num_y - 1, num_y, num_y + 1)))
				continue
			possible_list["[count]"] = list(i, j)
			count++

	for(var/bomb in 1 to generation_bombs)
		var/cell = pick(possible_list)
		var/coordinates = possible_list[cell]
		possible_list -= cell
		var/new_x = "[coordinates[1]]"
		var/new_y = "[coordinates[2]]"
		minesweeper_matrix[new_x][new_y]["bomb"] = TRUE

		if(new_x != "1")
			minesweeper_matrix["[text2num(new_x)-1]"][new_y]["around"] += 1

		if(new_y != "1")
			minesweeper_matrix[new_x]["[text2num(new_y)-1]"]["around"] += 1

		if(new_x != "1" && new_y != "1")
			minesweeper_matrix["[text2num(new_x)-1]"]["[text2num(new_y)-1]"]["around"] += 1

		if(new_x != "[generation_rows]")
			minesweeper_matrix["[text2num(new_x)+1]"][new_y]["around"] += 1

		if(new_y != "[generation_columns]")
			minesweeper_matrix[new_x]["[text2num(new_y)+1]"]["around"] += 1

		if(new_x != "[generation_rows]" && new_y != "[generation_columns]")
			minesweeper_matrix["[text2num(new_x)+1]"]["[text2num(new_y)+1]"]["around"] += 1

		if(new_x != "1" && new_y != "[generation_columns]")
			minesweeper_matrix["[text2num(new_x)-1]"]["[text2num(new_y)+1]"]["around"] += 1

		if(new_x != "[generation_rows]" && new_y != "1")
			minesweeper_matrix["[text2num(new_x)+1]"]["[text2num(new_y)-1]"]["around"] += 1

	first_touch = FALSE
	start_time = world.time

/datum/data/pda/app/game/minesweeper/proc/open_cell(x, y, start_cycle = TRUE)
	. = list()
	if(!minesweeper_matrix[x][y]["open"])
		minesweeper_matrix[x][y]["open"] = TRUE
		opened_cells += 1

		if(minesweeper_matrix[x][y]["flag"])
			minesweeper_matrix[x][y]["flag"] = FALSE
			setted_flags -= 1
			if(minesweeper_matrix[x][y]["bomb"])
				flagged_bombs -= 1

		if(minesweeper_matrix[x][y]["around"] == 0)
			if(start_cycle)
				update_zeros(x, y)
			else
				. = list(list(x, y))

/datum/data/pda/app/game/minesweeper/proc/update_zeros(x, y)
	var/list/list_for_update = list(list(x, y))
	for(var/list/coordinates in list_for_update)
		var/this_x = coordinates[1]
		var/this_y = coordinates[2]
		var/num_x = text2num(coordinates[1])
		var/num_y = text2num(coordinates[2])
		var/new_x
		var/new_y

		if(num_x != 1)
			new_x = "[num_x-1]"
			list_for_update += open_cell(new_x, this_y)

		if(num_y != 1)
			new_y = "[num_y-1]"
			list_for_update += open_cell(this_x, new_y)

		if(num_x != generation_rows)
			new_x = "[num_x+1]"
			list_for_update += open_cell(new_x, this_y)

		if(num_y != generation_columns)
			new_y = "[num_y+1]"
			list_for_update += open_cell(this_x, new_y)

		if(num_x != 1 && num_y != 1)
			new_x = "[num_x-1]"
			new_y = "[num_y-1]"
			if(minesweeper_matrix[new_x][this_y]["open"] && minesweeper_matrix[this_x][new_y]["open"])
				list_for_update += open_cell(new_x, new_y)

		if(num_x != generation_rows && num_y != generation_columns)
			new_x = "[num_x+1]"
			new_y = "[num_y+1]"
			if(minesweeper_matrix[new_x][this_y]["open"] && minesweeper_matrix[this_x][new_y]["open"])
				list_for_update += open_cell(new_x, new_y)

		if(num_x != 1 && num_y != generation_columns)
			new_x = "[num_x-1]"
			new_y = "[num_y+1]"
			if(minesweeper_matrix[new_x][this_y]["open"] && minesweeper_matrix[this_x][new_y]["open"])
				list_for_update += open_cell(new_x, new_y)

		if(num_x != generation_rows && num_y != 1)
			new_x = "[num_x+1]"
			new_y = "[num_y-1]"
			if(minesweeper_matrix[new_x][this_y]["open"] && minesweeper_matrix[this_x][new_y]["open"])
				list_for_update += open_cell(new_x, new_y)


#undef MINESWEEPER_ROWS
#undef MINESWEEPER_COLUMNS
#undef MINESWEEPER_BOMBS
