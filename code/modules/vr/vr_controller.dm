//Control file with the backbone for the vr rooms and avatars

var/datum/vr_rooms = list()
var/roomcap = 20

/datum/vr_room
	var/name = null
	var/datum/map_template/vr/template = null
	var/datum/space_chunk/chunk = null
	var/list/spawn_points = list()
	var/expires = 1

proc/make_vr_room(name, template, expires)
	var/datum/vr_room/R = new
	R.name = name
	R.template = template
	R.template = vr_templates[R.template]
	R.chunk = space_manager.allocate_space(R.template.width, R.template.height)
	R.expires = expires
	vr_rooms[R.name] = R
	R.template.load(locate(R.chunk.x,R.chunk.y,R.chunk.zpos), centered = FALSE)

	for(var/atom/landmark in R.chunk.search_chunk(GLOB.landmarks_list))
		if(landmark.name == "avatarspawn")
			R.spawn_points.Add(landmark)

//Control code for the avatars
proc/build_virtual_avatar(mob/living/carbon/human/H, location, datum/map_template/vr/level/template)
	if(!location)
		return
	var/mob/living/carbon/human/virtual_reality/vr_avatar
	location = get_turf(location)
	vr_avatar = new /mob/living/carbon/human/virtual_reality(location)
	if(istype(H, /mob/living/carbon/human/virtual_reality))
		var/mob/living/carbon/human/virtual_reality/V = H
		vr_avatar.real_me = V.real_me
	else
		vr_avatar.real_me = H
	vr_avatar.set_species(H.dna.species.type)
	vr_avatar.dna = H.dna.Clone()
	vr_avatar.name = H.name
	vr_avatar.real_name = H.real_name
	vr_avatar.undershirt = H.undershirt
	vr_avatar.underwear = H.underwear
	vr_avatar.UpdateAppearance()
	vr_avatar.equipOutfit(template.outfit)
	return vr_avatar

proc/control_remote(mob/living/carbon/human/H, mob/living/carbon/human/virtual_reality/vr_avatar)
	if(H.mind)
		H.mind.transfer_to(vr_avatar)

proc/spawn_vr_avatar(mob/living/carbon/human/H, datum/vr_room/room)
	room = vr_rooms[room]
	var/mob/living/carbon/human/virtual_reality/vr_human
	vr_human = build_virtual_avatar(H, pick(room.spawn_points), room.template)
	control_remote(H, vr_human)
	return vr_human

//Preloaded rooms
/hook/roundstart/proc/starting_levels()
	make_vr_room("Lobby", "lobby", 0)
	return 1