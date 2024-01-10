// Creates a single icon from a given /atom or /image.  Only the first argument is required.
// This proc is utterly HATEFUL
/proc/getFlatIcon(image/A, defdir, deficon, defstate, defblend, start = TRUE, no_anim = FALSE)
	//Define... defines.
	var/static/icon/flat_template = icon('icons/effects/effects.dmi', "nothing")

	#define BLANK icon(flat_template)
	#define SET_SELF(SETVAR) do { \
		var/icon/SELF_ICON=icon(icon(curicon, curstate, base_icon_dir),"",SOUTH,no_anim?1:null); \
		if(A.alpha<255) { \
			SELF_ICON.Blend(rgb(255,255,255,A.alpha),ICON_MULTIPLY);\
		} \
		if(A.color) { \
			if(islist(A.color)){ \
				SELF_ICON.MapColors(arglist(A.color))} \
			else{ \
				SELF_ICON.Blend(A.color,ICON_MULTIPLY)} \
		} \
		##SETVAR=SELF_ICON;\
		} while(0)
	#define INDEX_X_LOW 1
	#define INDEX_X_HIGH 2
	#define INDEX_Y_LOW 3
	#define INDEX_Y_HIGH 4

	#define flatX1 flat_size[INDEX_X_LOW]
	#define flatX2 flat_size[INDEX_X_HIGH]
	#define flatY1 flat_size[INDEX_Y_LOW]
	#define flatY2 flat_size[INDEX_Y_HIGH]
	#define addX1 add_size[INDEX_X_LOW]
	#define addX2 add_size[INDEX_X_HIGH]
	#define addY1 add_size[INDEX_Y_LOW]
	#define addY2 add_size[INDEX_Y_HIGH]

	if(!A || A.alpha <= 0)
		return BLANK

	var/noIcon = FALSE
	if(start)
		if(!defdir)
			defdir = A.dir
		if(!deficon)
			deficon = A.icon
		if(!defstate)
			defstate = A.icon_state
		if(!defblend)
			defblend = A.blend_mode

	var/curicon = A.icon || deficon
	var/curstate = A.icon_state || defstate

	if(!((noIcon = (!curicon))))
		var/curstates = icon_states(curicon)
		if(!(curstate in curstates))
			if("" in curstates)
				curstate = ""
			else
				noIcon = TRUE // Do not render this object.

	var/curdir
	var/base_icon_dir	//We'll use this to get the icon state to display if not null BUT NOT pass it to overlays as the dir we have

	//These should use the parent's direction (most likely)
	if(!A.dir || A.dir == SOUTH)
		curdir = defdir
	else
		curdir = A.dir

	//Try to remove/optimize this section ASAP, CPU hog.
	//Determines if there's directionals.
	if(!noIcon && curdir != SOUTH)
		var/exist = FALSE
		var/static/list/checkdirs = list(NORTH, EAST, WEST)
		for(var/i in checkdirs)		//Not using GLOB for a reason.
			if(length(icon_states(icon(curicon, curstate, i))))
				exist = TRUE
				break
		if(!exist)
			base_icon_dir = SOUTH
	//

	if(!base_icon_dir)
		base_icon_dir = curdir

	ASSERT(!BLEND_DEFAULT)		//I might just be stupid but lets make sure this define is 0.

	var/curblend = A.blend_mode || defblend

	if(A.overlays.len || A.underlays.len)
		var/icon/flat = BLANK
		// Layers will be a sorted list of icons/overlays, based on the order in which they are displayed
		var/list/layers = list()
		var/image/copy
		// Add the atom's icon itself, without pixel_x/y offsets.
		if(!noIcon)
			copy = image(icon=curicon, icon_state=curstate, layer=A.layer, dir=base_icon_dir)
			copy.color = A.color
			copy.alpha = A.alpha
			copy.blend_mode = curblend
			layers[copy] = A.layer

		// Loop through the underlays, then overlays, sorting them into the layers list
		for(var/process_set in 0 to 1)
			var/list/process = process_set? A.overlays : A.underlays
			for(var/i in 1 to process.len)
				var/image/current = process[i]
				if(!current)
					continue
				if(current.plane != FLOAT_PLANE && current.plane != A.plane)
					continue
				var/current_layer = current.layer
				if(current_layer < 0)
					if(current_layer <= -1000)
						return flat
					current_layer = process_set + A.layer + current_layer / 1000

				for(var/p in 1 to layers.len)
					var/image/cmp = layers[p]
					if(current_layer < layers[cmp])
						layers.Insert(p, current)
						break
				layers[current] = current_layer

		var/icon/add // Icon of overlay being added

		// Current dimensions of flattened icon
		var/list/flat_size = list(1, flat.Width(), 1, flat.Height())
		// Dimensions of overlay being added
		var/list/add_size[4]

		for(var/V in layers)
			var/image/I = V
			if(I.alpha == 0)
				continue

			if(I == copy) // 'I' is an /image based on the object being flattened.
				curblend = BLEND_OVERLAY
				add = icon(I.icon, I.icon_state, base_icon_dir)
			else // 'I' is an appearance object.
				add = getFlatIcon(image(I), curdir, curicon, curstate, curblend, FALSE, no_anim)
			if(!add)
				continue
			// Find the new dimensions of the flat icon to fit the added overlay
			add_size = list(
				min(flatX1, I.pixel_x+1),
				max(flatX2, I.pixel_x+add.Width()),
				min(flatY1, I.pixel_y+1),
				max(flatY2, I.pixel_y+add.Height())
			)

			if(flat_size ~! add_size)
				// Resize the flattened icon so the new icon fits
				flat.Crop(
				addX1 - flatX1 + 1,
				addY1 - flatY1 + 1,
				addX2 - flatX1 + 1,
				addY2 - flatY1 + 1
				)
				flat_size = add_size.Copy()

			// Blend the overlay into the flattened icon
			flat.Blend(add, blendMode2iconMode(curblend), I.pixel_x + 2 - flatX1, I.pixel_y + 2 - flatY1)

		if(A.color)
			if(islist(A.color))
				flat.MapColors(arglist(A.color))
			else
				flat.Blend(A.color, ICON_MULTIPLY)

		if(A.alpha < 255)
			flat.Blend(rgb(255, 255, 255, A.alpha), ICON_MULTIPLY)

		if(no_anim)
			//Clean up repeated frames
			var/icon/cleaned = new /icon()
			cleaned.Insert(flat, "", SOUTH, 1, 0)
			. = cleaned
		else
			. = icon(flat, "", SOUTH)
	else	//There's no overlays.
		if(!noIcon)
			SET_SELF(.)

	//Clear defines
	#undef flatX1
	#undef flatX2
	#undef flatY1
	#undef flatY2
	#undef addX1
	#undef addX2
	#undef addY1
	#undef addY2

	#undef INDEX_X_LOW
	#undef INDEX_X_HIGH
	#undef INDEX_Y_LOW
	#undef INDEX_Y_HIGH

	#undef BLANK
	#undef SET_SELF


//Imagine removing pixels from the main icon that are covered by pixels from the mask icon.
//Standard behaviour is to cut pixels from the main icon that are covered by pixels from the mask icon unless passed mask_ready, see below.
/proc/get_icon_difference(icon/main, icon/mask, mask_ready)
	/*You should skip prep if the mask is already sprited properly. This significantly improves performance by eliminating most of the realtime icon work.
	e.g. A 'ready' mask is a mask where the part you want cut out is missing (no pixels, 0 alpha) from the sprite, and everything else is solid white.*/

	if(istype(main) && istype(mask))
		if(!mask_ready) //Prep the mask if we're using a regular old sprite and not a special-made mask.
			mask.Blend(rgb(255,255,255), ICON_SUBTRACT) //Make all pixels on the mask as black as possible.
			mask.Opaque(rgb(255,255,255)) //Make the transparent pixels (background) white.
			mask.BecomeAlphaMask() //Make all the black pixels vanish (fully transparent), leaving only the white background pixels.

		main.AddAlphaMask(mask) //Make the pixels in the main icon that are in the transparent zone of the mask icon also vanish (fully transparent).
		return main

///Checks if the given iconstate exists in the given file, caching the result. Setting no_sprite to TRUE will print a stack trace ONCE.
/proc/icon_exists(file, state, no_sprite)
	var/static/list/icon_states_cache = list()
	if(icon_states_cache[file]?[state])
		return TRUE

	if(icon_states_cache[file]?[state] == FALSE)
		return FALSE

	var/list/states = icon_states(file)

	if(!icon_states_cache[file])
		icon_states_cache[file] = list()

	if(state in states)
		icon_states_cache[file][state] = TRUE
		return TRUE
	else
		icon_states_cache[file][state] = FALSE
		if(no_sprite)
			stack_trace("Icon Lookup for state: [state] in file [file] failed.")
		return FALSE
