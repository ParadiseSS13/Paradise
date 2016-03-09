// Based off of /datum/camerachunk, but for shadowlings

/datum/shadowchunk
	var/list/overlays = list()
	var/list/turfs = list()
	var/list/seenby = list()
	var/visible = 0
	var/changed = 0
	var/updating = 0
	var/x = 0
	var/y = 0
	var/z = 0

/mob/var/list/visible_shadow_chunks = list()

// Add a shadowling to the chunk, then update if changed.

/datum/shadowchunk/proc/add(mob/S)
	if(!S)
		return
	S.visible_shadow_chunks += src
	if(S.client)
		S.client.images += overlays
	visible++
	seenby += S
	//if(changed && !updating)
	//	update()

// Remove a shadowling from the chunk, then update if changed.

/datum/shadowchunk/proc/remove(mob/S)
	if(!S)
		return
	S.visible_shadow_chunks -= src
	if(S.client)
		S.client.images -= overlays
	seenby -= S
	if(visible > 0)
		visible--

/turf/var/image/shadowling_bright_overlay
/turf/var/atom/movable/bright_overlay_container

/datum/shadowchunk/New(loc, x, y, z)
	x &= ~15
	y &= ~15

	src.x = x
	src.y = y
	src.z = z

	for(var/turf/t in range(10, locate(x + 8, y + 8, z)))
		if(t.x >= x && t.y >= y && t.x < x + 16 && t.y < y + 16)
			turfs[t] = t

			if(!t.shadowling_bright_overlay)
				t.bright_overlay_container = new /atom/movable(t)
				t.bright_overlay_container.verbs.Cut()
				t.bright_overlay_container.mouse_opacity = 0
				t.bright_overlay_container.override = 1
				t.bright_overlay_container.name = ""
				t.shadowling_bright_overlay = image('icons/effects/shadowling_bright.dmi', t.bright_overlay_container, "overlay", 15)
				t.shadowling_bright_overlay.blend_mode = BLEND_ADD
				t.shadowling_bright_overlay.mouse_opacity = 0
				if(t.lighting_overlay)
					t.lighting_overlay.update_shadowling_overlay(t)

			overlays += t.shadowling_bright_overlay

/mob/proc/update_shadowling_chunks()
	if(!weakeyes)
		for(var/datum/shadowchunk/C in visible_shadow_chunks)
			C.remove(src)
		return
	
	var/x1 = max(0, x - 16) & ~15
	var/y1 = max(0, y - 16) & ~15
	var/x2 = min(world.maxx, x + 16) & ~15
	var/y2 = min(world.maxy, y + 16) & ~15

	var/list/visibleChunks = list()

	for(var/ix = x1; ix <= x2; ix += 16)
		for(var/iy = y1; iy <= y2; iy += 16)
			visibleChunks += get_shadow_chunk(ix, iy, z)

	var/list/remove = visible_shadow_chunks - visibleChunks
	var/list/add = visibleChunks - visible_shadow_chunks

	for(var/chunk in remove)
		var/datum/shadowchunk/C = chunk
		C.remove(src)

	for(var/chunk in add)
		var/datum/shadowchunk/C = chunk
		C.add(src)

/mob/Move()
	. = ..()
	update_shadowling_chunks()

var/list/shadow_chunks = list()
proc/get_shadow_chunk(x, y, z)
	x &= ~15
	y &= ~15
	var/key = "[x],[y],[z]"
	if(!shadow_chunks[key])
		shadow_chunks[key] = new /datum/shadowchunk(null, x, y, z)

	return shadow_chunks[key]
