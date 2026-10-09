use byondapi::value::ByondValue;
use dbpnoise::gen_noise;
use noise::{Perlin, NoiseFn};

const OFFSET: f32 = 0.5;

#[byondapi::bind]
fn perlin_generate_binary(
    seed: ByondValue,
    stamp_size: ByondValue,
    world_size: ByondValue,
    lower_range: ByondValue,
    upper_range: ByondValue,
) -> eyre::Result<ByondValue> {
    Ok(gen_perlin_binary(
        seed.get_string()?.parse::<u32>()?,
        stamp_size.get_string()?.parse::<u32>()?,
        world_size.get_string()?.parse::<u32>()?,
        lower_range.get_string()?.parse::<f32>()?,
        upper_range.get_string()?.parse::<f32>()?,
    )?
    .try_into()?)
}

fn gen_perlin_binary(
    seed: u32,
    _stamp_size: u32,
    world_size: u32,
    lower_range: f32,
    upper_range: f32,
) -> eyre::Result<String> {
    let noise: Perlin = Perlin::new(seed);
    let mut val: f64;
    let mut valbool: bool;
    let mut result = String::new();
    for x in 0..world_size {
        for y in 0..world_size {
            val = noise.get([(x as f32 + OFFSET) as f64, (y as f32 + OFFSET) as f64]);
            valbool = lower_range < (val as f32) && (val as f32) < upper_range;
            result.push(if valbool {'1'} else {'0'});
        }
    }
    Ok(result)
}

/// Generate a perlin noise map with additional control on octave count and divisor and frequency
#[byondapi::bind]
fn perlin_generate_advanced(
    seed: ByondValue,
    world_size: ByondValue,
    frequency: ByondValue,
    divisor: ByondValue,
    octaves: ByondValue,
) -> eyre::Result<ByondValue> {
    Ok(gen_perlin_advanced(
        seed.get_string()?.parse::<u32>()?,
        world_size.get_string()?.parse::<u32>()?,
        frequency.get_string()?.parse::<f32>()?,
        divisor.get_string()?.parse::<f32>()?,
        octaves.get_string()?.parse::<u32>()?,
    )?
    .try_into()?)
}

fn gen_perlin_advanced(
    seed: u32,
    world_size: u32,
    frequency: f32,
    mut divisor: f32,
    octaves: u32,
) -> eyre::Result<String> {
    let noise = Perlin::new(seed);
    if divisor == 0.0 {
        divisor = 2.0 - 2.0_f32.powi(1 - octaves as i32); // 1.0, 1.5, 1.75, ...
    }

    let mut result: String = String::with_capacity((world_size * world_size) as usize);

    for x in 0..world_size {
        for y in 0..world_size {
            let mut sum = 0.0;

            for octave in 0..octaves{
                let scale = 2_f64.powi(octave as i32);
                let amplitude = 1.0 / scale;

                let xn = ((x as f64 + OFFSET as f64) * scale) * frequency as f64;
                let yn = ((y as f64 + OFFSET as f64) * scale) * frequency as f64;

                sum += amplitude * noise.get([xn, yn]);
            }

            let normalized = (sum / divisor as f64 + 1.0) / 2.0;
            let value = (normalized * 9.0).round() as u8;

            result.push((b'0' + value) as char);
        }
    }
    Ok(result)
}

/// Generate a perlin noise map with distance lerping to force an 'island' cluster
#[byondapi::bind]
fn perlin_generate_advanced_dlerp(
    seed: ByondValue,
    world_size: ByondValue,
    frequency: ByondValue,
    divisor: ByondValue,
    octaves: ByondValue,
    mix: ByondValue,
) -> eyre::Result<ByondValue> {
    Ok(gen_perlin_advanced_dlerp(
        seed.get_string()?.parse::<u32>()?,
        world_size.get_string()?.parse::<u32>()?,
        frequency.get_string()?.parse::<f32>()?,
        divisor.get_string()?.parse::<f32>()?,
        octaves.get_string()?.parse::<u32>()?,
        mix.get_string()?.parse::<f32>()?,
    )?
    .try_into()?)
}

fn gen_perlin_advanced_dlerp(
    seed: u32,
    world_size: u32,
    frequency: f32,
    mut divisor: f32,
    octaves: u32,
    mix: f32,
) -> eyre::Result<String> {
    let noise = Perlin::new(seed);

    if divisor == 0.0 {
        divisor = 2.0 - 2.0_f32.powi(1 - octaves as i32);
    }

    let mut result = String::with_capacity((world_size as usize) * (world_size as usize));

    for x in 0..world_size {
        for y in 0..world_size {
            let mut sum = 0.0;

            for octave in 0..octaves {
                let scale = 2_u32.pow(octave) as f64;

                let xn = (x as f64 + OFFSET as f64) * scale * frequency as f64;
                let yn = (y as f64 + OFFSET as f64) * scale * frequency as f64;

                sum += noise.get([xn, yn]) / scale;
            }

            let dx = (x as f64 / (world_size - 1) as f64) * 2.0 - 1.0;
            let dy = (y as f64 / (world_size - 1) as f64) * 2.0 - 1.0;
            let d = 1.0 - (1.0 - dx.powi(2)) * (1.0 - dy.powi(2));
            let noise_value = sum / divisor as f64;

            let lerped = noise_value + ((1.0 - d) - noise_value) * mix as f64;
            let normalized = lerped.clamp(0.0, 1.0);

            let value = (normalized * 9.0).round() as u8;
            result.push((b'0' + value) as char);
        }
    }
    Ok(result)
}

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
