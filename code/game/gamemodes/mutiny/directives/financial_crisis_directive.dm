datum/directive/terminations/financial_crisis
	special_orders = list(
		"Suspend financial accounts of all support personnel, excluding the Head of Personnel.",
		"Transfer their payrolls to the station account.",
		"Terminate their employment.")

datum/directive/terminations/financial_crisis/get_crew_to_terminate()
	var/list/support[0]
	var/list/candidates = support_positions - "Head of Personnel"
	for(var/mob/M in player_list)
		if (M.is_ready() && candidates.Find(M.mind.assigned_role))
			support+=(M)
	return support

datum/directive/terminations/financial_crisis/get_description()
	return {"
		<p>
			[system_name()] system banks in financial crisis. Local emergency situation ongoing.
			NT Funds redistributed in accordance with financial regulations covered by employee contracts, impact upon civilian department expected.
			Further information is classified.
		</p>
	"}

datum/directive/terminations/financial_crisis/meets_prerequisites()
	var/list/support = get_crew_to_terminate()
	return support.len >= 5
