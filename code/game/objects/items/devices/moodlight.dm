/obj/item/moodlight
	name = "RGB Moodlight"
	desc = "A customizable RGB LED Moodlight that smoothly fades between colors. Perfect for SpaceTok!"
	icon = 'icons/obj/device.dmi'
	icon_state = "moodlight_off"
	item_state = "moodlight_off"
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 7
	materials = list(MAT_METAL = 300, MAT_GLASS = 300)
	origin_tech = "magnets=2;combat=1"
	var/activated = FALSE
	var/list/colors = list()
	var/list/choices = list("Toggle Power", "Add a color", "Remove a color", "Set Range", "Set Brightness")
	var/first_color	//This is the current color we are on, not the first color in the list.
	var/second_color //This is the color we are currently shifting to, from first_color
	var/amount_shifted //This should always be a decimal number from 0 to 1 as this is used for the percentage in BlendRGB.
	var/i = 1 //Iteration. Example: Shifting from color 1 to color 2, then shifting from color 2 to color 3. That would be 2 iterations.
	var/range = 4
	var/brightness = 2

/obj/item/moodlight/attack_self(mob/user)
	var/choice = input(user, "What do you want to do?") as null|anything in sortTim(choices, /proc/cmp_text_asc)
	switch(choice)
		if("Toggle Power")
			if(length(colors) == 0)
				to_chat(user, "<span class = 'warning'>Select some colors first!</span>")
				return
			toggle_shift(!activated)
			visible_message("<span class = 'notice'>[user] turns [activated ? "on" : "off"] the [src]!</span>")
		if("Add a color")
			if(activated)
				to_chat(user, "<span class = 'warning'>Turn it off first!</span>")
				return

			var/new_color = input(user, "Please select a color") as color
			colors += new_color
		if("Remove a color")
			if(activated)
				to_chat(user, "<span class = 'warning'>Turn it off first!</span>")
				return

			var/remove_this_color = input(user, "Please select a color") as null|anything in colors
			if(!remove_this_color) //they cancelled
				return
			colors -= remove_this_color
		if("Set Range")
			var/new_range = input(user, "Please input a range from 1-6. Default is 4.") as num
			if(new_range > 6 || new_range < 1)
				to_chat(user, "<span class = 'warning'>Choose a level between 1-6!</span>")
				return
			range = new_range
		if("Set Brightness")
			var/new_brightness = input(user, "Please input a brightness from 0-2. Default is 2. Decimals allowed.") as num
			if(new_brightness > 2 || new_brightness <= 0)
				to_chat(user, "<span class = 'warning'>Choose a level between 0-2!</span>")
				return
			brightness = new_brightness
		

/obj/item/moodlight/extinguish_light() //for shadowlings
	toggle_shift(FALSE)

/obj/item/moodlight/proc/toggle_shift(active)
	first_color = colors[1]
	second_color = colors[2]
	icon_state = "moodlight_[active ? "on" : "off"]"
	item_state = "moodlight_[active ? "on" : "off"]"
	activated = active
	if(length(colors) == 1) //If there is only 1 color we dont need to process anything
		set_light(range, brightness, colors[1])
		color = colors[1]
		return
	if(active)
		START_PROCESSING(SSfastprocess, src)
	else
		STOP_PROCESSING(SSfastprocess, src)
		set_light(0)
		color = null


/obj/item/moodlight/proc/check_end_state()
	return i == length(colors)

/obj/item/moodlight/process()
	if(!activated)
		return

	amount_shifted = amount_shifted + 0.005 //The smaller the number the smoother the shift, but the longer it will take to shift.

	if(amount_shifted >= 1) //Step to the next color because we have already shifted 100% of our current shift.
		amount_shifted = 0
		i++
		if(check_end_state()) //let the ending code handle it now
			return
		first_color = colors[i]
		second_color = colors[i+1]

	if(length(colors) == i) //We have reached the end of the list and need to go back to the start
		i = 1
		amount_shifted = 0
		if(first_color == colors[length(colors)]) //We do this because example: Green = First in Colors list. Pink = Second in Colors list. We can go from green to pink and pink back to green, but then it will abruptly jump back to pink because that is the last item in the list, mainly a problem with only 2 colors in the list. This prevents that.
			first_color = colors[i]
			second_color = colors[i+1]
		else
			first_color = colors[length(colors)] //We do the last entry in the colors list, because that is what the light is currently set at. Or else it will abruptly jump instead of smoothly changing.
			second_color = colors[i]
	
	var/new_color = BlendRGB(first_color, second_color, amount_shifted)
	set_light(range, brightness, new_color)
	color = new_color

