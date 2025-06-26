/proc/cmp_ruin_placement_size(datum/map_template/ruin/A, datum/map_template/ruin/B) // SS220 EDIT - compare ruins by size
	return A.get_size() - B.get_size()
