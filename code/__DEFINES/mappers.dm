/// Create directional subtypes for a path to simplify mapping.
#define MAPPING_DIRECTIONAL_HELPERS(path, offset_y, offset_x) ##path/directional/north {\
	name = "north bump"; \
	dir = NORTH; \
	pixel_y = offset_y; \
} \
##path/directional/south {\
	name = "south bump"; \
	dir = SOUTH; \
	pixel_y = -offset_y; \
} \
##path/directional/east {\
	name = "east bump"; \
	dir = EAST; \
	pixel_x = offset_x; \
} \
##path/directional/west {\
	name = "west bump"; \
	dir = WEST; \
	pixel_x = -offset_x; \
}
