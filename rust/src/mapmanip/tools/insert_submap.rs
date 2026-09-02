use crate::mapmanip::GridMap;
use dmmtools::dmm;
use dmmtools::dmm::Coord3;
use eyre::ContextCompat;

/// Takes `src_map` and puts it at `coord` in `dst_map`.
/// Noop area and turf have special handling: `/area/template_noop` and `/turf/template_noop`.
/// If a `src` tile has noop area, then it uses the mapped in `dst` area instead of replacing it.
/// If a `src` tile has noop turf, then it uses the mapped in `dst` turf instead of replacing it,
/// and additionally also merges `src` objects and mobs with the `dst` mapped in ones.
pub fn insert_submap(
    src_map: &GridMap,
    coord: dmm::Coord3,
    dst_map: &mut GridMap,
) -> eyre::Result<()> {
    for x in 1..(src_map.size.x + 1) {
        for y in 1..(src_map.size.y + 1) {
            for z in 1..(src_map.size.z + 1) {
                let coord_src = Coord3::new(x, y, z);
                let coord_dst = Coord3::new(coord.x + x - 1, coord.y + y - 1, coord.z + z - 1);

                // get src tile
                let mut tile_src = src_map
                    .grid
                    .get(&coord_src)
                    .wrap_err(format!(
                        "src submap coord out of bounds: {coord_src}; {}; {};",
                        src_map.size,
                        src_map.grid.len(),
                    ))?
                    .clone();

                // remove area and turf from src tile
                let tile_src_area = tile_src.remove_area().wrap_err("submap tile has no area")?;
                let tile_src_turf = tile_src.remove_turf().wrap_err("submap tile has no turf")?;

                let tile_src_area_is_noop = { tile_src_area.path == "/area/template_noop" };
                let tile_src_turf_is_noop = { tile_src_turf.path == "/turf/template_noop" };

                // get dst tile
                let tile_dst = dst_map.grid.get_mut(&coord_dst).wrap_err(format!(
                    "cannot insert submap tile; coord out of bounds; x: {x}; y: {y};"
                ))?;

                // remove area and turf from dst tile
                let tile_dst_area = tile_dst.remove_area().wrap_err("map tile has no area")?;
                let tile_dst_turf = tile_dst.remove_turf().wrap_err("map tile has no turf")?;

                // get new area
                let new_area = if tile_src_area_is_noop {
                    tile_dst_area
                } else {
                    tile_src_area
                };

                // get new turf, AND, append/replace other atoms into dst tile
                let new_turf = if tile_src_turf_is_noop {
                    tile_dst.prefabs.append(&mut tile_src.prefabs);
                    tile_dst_turf
                } else {
                    tile_dst.prefabs = tile_src.prefabs;
                    tile_src_turf
                };

                // push selected new turf and area to dst tile
                // do note that in dmm file format
                // turf and area have to be the two last elements in a prefab
                tile_dst.prefabs.push(new_turf);
                tile_dst.prefabs.push(new_area);
            }
        }
    }

    Ok(())
}
