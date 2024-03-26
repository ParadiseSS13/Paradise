/// Create directional subtypes for a path to simplify mapping.
#define MAPPING_DIRECTIONAL_HELPERS(path, offset_y, offset_x) ##path/directional/north {\
	dir = NORTH; \
	pixel_y = offset_y; \
} \
##path/directional/south {\
	dir = SOUTH; \
	pixel_y = -offset_y; \
} \
##path/directional/east {\
	dir = EAST; \
	pixel_x = offset_x; \
} \
##path/directional/west {\
	dir = WEST; \
	pixel_x = -offset_x; \
}
