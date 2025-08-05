use byondapi::value::ByondValue;
use dbpnoise::gen_noise;

#[byondapi::bind]
fn dbp_generate(
    seed: ByondValue,
    accuracy: ByondValue,
    stamp_size: ByondValue,
    world_size: ByondValue,
    lower_range: ByondValue,
    upper_range: ByondValue,
) -> eyre::Result<ByondValue> {
    Ok(gen_dbp_noise(
        &seed.get_string()?,
        &accuracy.get_string()?,
        &stamp_size.get_string()?,
        &world_size.get_string()?,
        &lower_range.get_string()?,
        &upper_range.get_string()?,
    )?
    .try_into()?)
}

fn gen_dbp_noise(
    seed: &str,
    accuracy: &str,
    stamp_size: &str,
    world_size: &str,
    lower_range: &str,
    upper_range: &str,
) -> eyre::Result<String> {
    let map: Vec<Vec<bool>> = gen_noise(
        seed,
        accuracy.parse::<usize>()?,
        stamp_size.parse::<usize>()?,
        world_size.parse::<usize>()?,
        lower_range.parse::<f32>()?,
        upper_range.parse::<f32>()?,
    );
    let mut result = String::new();
    for row in map {
        for cell in row {
            result.push(if cell { '1' } else { '0' });
        }
    }
    Ok(result)
}

#[cfg(test)]
mod tests {
    use super::gen_dbp_noise;

    const TEST_SEED: &str = "meowrrpmraoooow~";
    #[test]
    fn test_gen_dbp_noise() {
        let value = gen_dbp_noise(TEST_SEED, "360", "4", "25", "0.1", "1.1").unwrap();
        println!("(length: {})", value.len());
        println!("{}", value);
        assert_eq!(value.len(), 625);
    }
}
