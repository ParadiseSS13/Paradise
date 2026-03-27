RESTRICT_TYPE(/datum/team/uplifted_primitive)

/// The number of players a team must have before receiving their team objective.
#define TEAM_OBJECTIVE_MEMBER_THRESHOLD 3

/// An team containing all uplifted primitives of a given species.
/datum/team/uplifted_primitive
	name = "Uplifted Primitives"

	/// The species this team represents.
	var/datum/species/team_species
	/// The antag hud specific to this team, only shown to other members of the team.
	var/datum/atom_hud/antag/team_hud = new()

	/// Whether or not the team objective has been added yet.
	var/has_added_team_objective = FALSE

	/// All potential objectives which can be added as the team objective.
	var/list/potential_objectives = list(
		/datum/objective/uplifted/build_nest_in_area,
	)

	/// The number of spawns that should always poll ghosts for nests of this team.
	var/guaranteed_sentient_spawns = 0

/datum/team/uplifted_primitive/New(list/starting_members, datum/species/new_species = /datum/species/monkey)
	team_species = new_species
	return ..(starting_members)

/datum/team/uplifted_primitive/create_team(list/starting_members)
	. = ..()
	name = "[team_species::name] Uprising"

	add_team_objective(/datum/objective/uplifted/propagate)

/datum/team/uplifted_primitive/can_create_team()
	return SSticker.mode.uplifted_teams[team_species] == null

/datum/team/uplifted_primitive/assign_team(list/starting_members)
	SSticker.mode.uplifted_teams[team_species] = src

/datum/team/uplifted_primitive/clear_team_reference()
	SSticker.mode.uplifted_teams[team_species] = null
	SSticker.mode.uplifted_teams -= team_species

/datum/team/uplifted_primitive/handle_adding_member(datum/mind/new_member)
	..()

	if(!has_added_team_objective && length(members) >= TEAM_OBJECTIVE_MEMBER_THRESHOLD)
		var/selected_objective_path = pick(potential_objectives)
		var/datum/objective/new_objective = new selected_objective_path()
		add_team_objective(new_objective)
		announce_new_objective(members - new_member, new_objective)
		has_added_team_objective = TRUE

/datum/team/uplifted_primitive/proc/announce_new_objective(list/announce_to, datum/objective/new_objective)
	var/message = prepare_new_objective_message(new_objective)
	for(var/datum/mind/member in announce_to)
		if(!member.current || !isliving(member.current))
			continue
		to_chat(member.current, message)
		SEND_SOUND(member.current, sound('sound/ambience/alarm4.ogg'))

/datum/team/uplifted_primitive/proc/prepare_new_objective_message(datum/objective/new_objective)
	var/list/messages = list()

	messages += SPAN_USERDANGER("Your species grows!")
	messages += SPAN_NOTICE("With your numbers rising, you devise a new objective:")
	messages += new_objective.explanation_text

	return chat_box_red(messages.Join("<br>"))

#undef TEAM_OBJECTIVE_MEMBER_THRESHOLD
