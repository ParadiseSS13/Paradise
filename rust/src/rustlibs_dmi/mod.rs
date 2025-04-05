use byondapi::value::ByondValue;
use png::{Decoder, Encoder};
use std::fs::File;

#[byondapi::bind]
fn dmi_strip_metadata(path: ByondValue) -> eyre::Result<ByondValue> {
    strip_metadata(&path.get_string()?)?;
    Ok(ByondValue::null())
}

fn strip_metadata(path: &str) -> eyre::Result<()> {
    let mut reader = Decoder::new(File::open(path)?).read_info()?;
    let mut buf = vec![0; reader.output_buffer_size()];
    let frame_info = reader.next_frame(&mut buf)?;

    let mut encoder = Encoder::new(File::create(path)?, frame_info.width, frame_info.height);
    encoder.set_color(frame_info.color_type);
    encoder.set_depth(frame_info.bit_depth);
    let reader_info = reader.info();

    if let Some(palette) = reader_info.palette.clone() {
        encoder.set_palette(palette);
    }
    if let Some(trns_chunk) = reader_info.trns.clone() {
        encoder.set_palette(trns_chunk);
    }

    let mut writer = encoder.write_header()?;
    Ok(writer.write_image_data(&buf)?)
}
