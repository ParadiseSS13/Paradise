use crate::mapmanip::core::GridMap;
use dmmtools::dmm;
use dmmtools::dmm::Coord3;
use eyre::ContextCompat;

/// Returns part of map of `xtr_size` and at `xtr_coord` from `src_map`.
pub fn extract_submap(
    src_map: &GridMap,
    xtr_coord: dmm::Coord3,
    xtr_size: dmm::Coord3,
) -> eyre::Result<GridMap> {
    let mut dst_map = GridMap {
        size: xtr_size,
        grid: crate::mapmanip::core::TileGrid::new(xtr_size.x, xtr_size.y, xtr_size.z),
    };

    for x in 1..(xtr_size.x + 1) {
        for y in 1..(xtr_size.y + 1) {
            for z in 1..(xtr_size.z + 1) {
                let src_x = xtr_coord.x + x - 1;
                let src_y = xtr_coord.y + y - 1;
                let src_z = xtr_coord.z + z - 1;

                let tile = src_map
                    .grid
                    .get(&Coord3::new(src_x, src_y, src_z))
                    .wrap_err(format!(
                        "cannot extract submap; coords out of bounds; x: {src_x}; y: {src_y}; z: {src_z}"
                    ))?;

                dst_map.grid.insert(&Coord3::new(x, y, z), tile.clone());
            }
        }
    }

    Ok(dst_map)
}
