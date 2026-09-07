use crate::mapmanip::GridMap;
use dmmtools::dmm::{self, Coord3};
use eyre::ContextCompat;
use fxhash::FxHashMap;
use std::collections::BTreeSet;

fn coord3_to_index(coord: dmm::Coord3, size: dmm::Coord3) -> (usize, usize, usize) {
    (
        coord.z as usize - 1,
        (size.y - coord.y) as usize,
        coord.x as usize - 1,
    )
}

fn int_to_key(i: u16) -> dmm::Key {
    // Unsafe is used here to convert basic int to key type, as `dmm::Key` interior var is private.
    // This is "safe", as key will always be `u16` to maintain compability with the `dmm` format.
    // Could be at some point be made safe when the key type is made public in the `dmm_tools` crate.
    unsafe { std::mem::transmute::<u16, dmm::Key>(i) }
}

pub fn to_dict_map(grid_map: &GridMap) -> eyre::Result<dmm::Map> {
    let mut dict_map = dmm::Map::new(
        grid_map.size.x as usize,
        grid_map.size.y as usize,
        grid_map.size.z as usize,
        "".to_string(),
        "".to_string(),
    );
    dict_map.dictionary.clear();

    let mut used_dict_keys = BTreeSet::<dmm::Key>::new();

    let mut dictionary_reverse = FxHashMap::<Vec<dmm::Prefab>, dmm::Key>::default();

    for tile in grid_map.grid.values() {
        if !dictionary_reverse.contains_key(&tile.prefabs) {
            if used_dict_keys.contains(&tile.key_suggestion) {
                let next_free_key = (0..65534)
                    .map(int_to_key)
                    .find(|k| !used_dict_keys.contains(k))
                    .wrap_err("ran out of free keys")?;
                dictionary_reverse.insert(tile.prefabs.clone(), next_free_key);
                used_dict_keys.insert(next_free_key);
            } else {
                dictionary_reverse.insert(tile.prefabs.clone(), tile.key_suggestion);
                used_dict_keys.insert(tile.key_suggestion);
            }
        }
    }

    for x in 1..(grid_map.size.x + 1) {
        for y in 1..(grid_map.size.y + 1) {
            for z in 1..(grid_map.size.z + 1) {
                let coord = Coord3::new(x, y, z);
                if let Some(tile) = grid_map.grid.get(&coord) {
                    let key = *dictionary_reverse.get(&tile.prefabs).unwrap();
                    dict_map.dictionary.insert(key, tile.prefabs.clone());
                    dict_map.grid[coord3_to_index(coord, grid_map.size)] = key;
                } else {
                    eyre::bail!("to_dict_map fail; grid map has no coord: {coord:?}");
                }
            }
        }
    }

    dict_map.adjust_key_length();

    Ok(dict_map)
}
