use super::Tile;
use crate::mapmanip::core::GridMap;
use dmmtools::dmm::{self, Coord3};
use std::ops::Index;

fn tuple_to_size(xyz: (usize, usize, usize)) -> Coord3 {
    Coord3::new(xyz.0 as i32, xyz.1 as i32, xyz.2 as i32)
}

pub fn to_grid_map(dict_map: &dmm::Map) -> GridMap {
    let mut grid_map = GridMap {
        size: tuple_to_size(dict_map.dim_xyz()),
        grid: crate::mapmanip::core::TileGrid::new(
            dict_map.dim_xyz().0 as i32,
            dict_map.dim_xyz().1 as i32,
            dict_map.dim_xyz().2 as i32,
        ),
    };

    for x in 1..grid_map.size.x + 1 {
        for y in 1..grid_map.size.y + 1 {
            for z in 1..grid_map.size.z + 1 {
                let coord = dmm::Coord3::new(x, y, z);
                let key = dict_map.index(coord);
                let prefabs = dict_map.dictionary[key].clone();
                let tile = Tile {
                    key_suggestion: *key,
                    prefabs,
                };
                let coord = dmm::Coord3::new(coord.x, coord.y, coord.z);
                grid_map.grid.insert(&coord, tile);
            }
        }
    }

    grid_map
}
