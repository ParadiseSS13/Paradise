// Originally coded by ISaidNo, later modified by Kelenius. Ported from Baystation12.

/obj/structure/closet/crate/secure/loot
	name = "abandoned crate"
	desc = "What could be inside?"
	icon_state = "securecrate"
	base_icon_state = "securecrate"
	integrity_failure = 0 //no breaking open the crate
	var/code = null
	/// Associated list of previous attempts w/ bulls & cows
	var/list/previous_attempts = list()
	var/attempts = 10
	var/code_length = 4
	var/qdel_on_open = FALSE
	var/spawned_loot = FALSE
	tamperproof = 90
	/// what game mode the crate is using, "numbers" for deca-code (bulls & cows), "words" for wordle
	var/game_mode = "numbers"

/obj/structure/closet/crate/secure/loot/Initialize(mapload)
	. = ..()

	// deciding if we're playing wordle or bulls & cows
	var/mode_roll = rand(1, 2)
	switch(mode_roll)
		if(1)
			game_mode = "numbers"
			code = generate_code(code_length)
		if(2)
			game_mode = "words"
			code_length = 5
			attempts = 6
			code = generate_word()

/// generating numbers that do not repeat
/obj/structure/closet/crate/secure/loot/proc/generate_code(length)
	var/list/digits = list("1", "2", "3", "4", "5", "6", "7", "8", "9", "0")
	var/list/code_digits = list()

	for(var/i in 1 to length)
		if(!digits.len)
			break
		var/digit = pick(digits)
		code_digits += digit
		digits -= digit //there are never matching digits in the answer

	return code_digits.Join("")

/// we pick our word here from wordle_words
/obj/structure/closet/crate/secure/loot/proc/generate_word()
	// if wordle_words isn't found, default to "SPACE"
	if(!GLOB.wordle_words?.len)
		return "SPACE"

	// go ahead and capatilize the word for STYLE
	return uppertext(pick(GLOB.wordle_words))

/obj/structure/closet/crate/secure/loot/proc/spawn_loot()
	spawned_loot = TRUE
	return

/// making sure that the player actually enters a 5 letter word
/obj/structure/closet/crate/secure/loot/proc/validate_word_input(input)
	if(!input || length(input) != 5)
		return FALSE

	// Check if all characters are letters
	for(var/i = 1 to length(input))
		var/char = input[i]
		if(!((char >= "A" && char <= "Z") || (char >= "a" && char <= "z")))
			return FALSE

	return TRUE

/obj/structure/closet/crate/secure/loot/attack_hand(mob/user, list/modifiers)
	if(!locked)
		return ..()
	if(!in_range(src, user))
		return

	var/prompt_title
	var/prompt_message

	switch(game_mode)
		if("words")
			prompt_title = "Word Lock"
			prompt_message = "Enter a [code_length]-letter word."
		else
			prompt_title = "Deca-code lock"
			prompt_message = "Enter [code_length] digits. All digits must be unique."

	var/input = tgui_input_text(user, title = prompt_title, message = prompt_message, max_length = code_length)

	if(game_mode == "words")
		input = uppertext(input)

	if(input == code)
		if(!spawned_loot)
			spawn_loot()
		tamperproof = 0 // set explosion chance to zero, so we dont accidently hit it with a multitool and instantly die
		togglelock(user)
		SStgui.close_user_uis(user, src)
		return

	if(!validate_input(input))
		to_chat(user, SPAN_NOTICE("You leave the crate alone."))
		return

	to_chat(user, SPAN_WARNING("A red light flashes."))
	previous_attempts += list(bulls_and_cows(input))
	attempts--

	if(attempts <= 0)
		boom(user)

/obj/structure/closet/crate/secure/loot/proc/validate_input(input)
	if(game_mode == "words")
		return validate_word_input(input)

	if(!input || code_length != length(input))
		return FALSE

	var/list/used_digits = list()
	for(var/i = 1 to length(input))
		var/char = input[i]
		if(!(char >= "0" && char <= "9")) //if a non-digit is found, reject the input
			return FALSE
		if(char in used_digits) //if a digit is repeated, reject the input
			return FALSE
		used_digits += char

	return TRUE

/obj/structure/closet/crate/secure/loot/ui_state(mob/user)
	return GLOB.physical_state

/obj/structure/closet/crate/secure/loot/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AbandonedCrate", name)
		ui.open()

/obj/structure/closet/crate/secure/loot/ui_data(mob/user)
	var/list/data = list()

	data["previous_attempts"] = previous_attempts
	data["attempts_left"] = attempts
	data["game_mode"] = game_mode
	data["code_length"] = code_length

	return data

/obj/structure/closet/crate/secure/loot/multitool_act(mob/living/user, obj/item/tool)
	if(!locked)
		return
	if(Adjacent(user))
		ui_interact(user)

	return TRUE

/// Implements bulls and cows algorithm to compare guess against actual code
/obj/structure/closet/crate/secure/loot/proc/bulls_and_cows(guess)
	// Safety check - never return null
	if(!guess)
		return list("attempt" = "", "bulls" = 0, "cows" = 0)

	if(game_mode == "words")
		return check_word_guess(guess)

	var/bulls = 0
	var/cows = 0

	for(var/i = 1 to code_length)
		var/guess_char = guess[i]
		var/code_char = code[i]

		if(guess_char == code_char)
			bulls++
		else if(findtext(code, guess_char))
			cows++

	return list("attempt" = guess, "bulls" = bulls, "cows" = cows)

/// Implements Wordle algorithm - returns letter states
/obj/structure/closet/crate/secure/loot/proc/check_word_guess(guess)
	guess = uppertext(guess)
	var/list/letter_states = list()
	var/list/code_letters = list()

	// Build a list of available letters from the code
	for(var/i = 1 to length(code))
		code_letters += code[i]

	// First pass: mark correct positions (green)
	for(var/i = 1 to length(guess))
		var/guess_char = guess[i]
		var/code_char = code[i]

		if(guess_char == code_char)
			letter_states += "correct"
			code_letters -= guess_char // Remove from available
		else
			letter_states += "unknown" // Placeholder

	// Second pass: mark wrong positions (yellow) and incorrect (gray)
	for(var/i = 1 to length(guess))
		if(letter_states[i] != "unknown")
			continue

		var/guess_char = guess[i]
		if(guess_char in code_letters)
			letter_states[i] = "present"
			code_letters -= guess_char // Remove one instance
		else
			letter_states[i] = "absent"

	return list("attempt" = guess, "letter_states" = letter_states)

/obj/structure/closet/crate/secure/loot/emag_act(mob/user, obj/item/card/emag/emag_card)
	. = ..()

	if(locked)
		boom(user) // no feedback since it just explodes, thats its own feedback
		return TRUE
	return

/obj/structure/closet/crate/secure/loot/togglelock(mob/user, silent = FALSE)
	if(!locked)
		. = ..() //Run the normal code.
		if(locked) //Double check if the crate actually locked itself when the normal code ran.
			//reset the anti-tampering, number of attempts and last attempt when the lock is re-enabled.
			tamperproof = initial(tamperproof)
			attempts = initial(attempts)
			previous_attempts = list()
		return
	if(tamperproof)
		return
	return ..()

/obj/structure/closet/crate/secure/loot/deconstruct(disassembled = TRUE)
	if(locked)
		boom()
		return
	return ..()

/obj/structure/closet/crate/secure/loot/open(mob/living/user, force = FALSE)
	. = ..()
	if(. && qdel_on_open)
		qdel(src)
