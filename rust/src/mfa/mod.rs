use byondapi::value::ByondValue;
use totp_rs::{Algorithm, Secret, TOTP};

const ISSUER: &str = "Paradise Station";

// This is a common method to ensure parameters stay the same between creation and verification
fn instance_totp_manager(secret: String, accname: String) -> TOTP {
    TOTP::new(
        Algorithm::SHA1,
        6,
        1,
        30,
        Secret::Encoded(secret.to_owned()).to_bytes().unwrap(),
        Some(ISSUER.to_string()),
        accname.to_owned(),
    )
    .unwrap() // who needs safety lmao
}

#[byondapi::bind]
fn mfa_generate_secret() -> eyre::Result<ByondValue> {
    let mfa_secret = Secret::generate_secret().to_encoded().to_string();

    Ok(ByondValue::new_str(mfa_secret)?)
}

#[byondapi::bind]
fn mfa_generate_qr(secret: ByondValue, ckey: ByondValue) -> eyre::Result<ByondValue> {
    let secret_str = secret.get_string()?;
    let ckey_str = ckey.get_string()?;

    // Get the QR from our secret
    let png_base64 = instance_totp_manager(secret_str, ckey_str)
        .get_qr_base64()
        .unwrap();

    // Send it back
    Ok(ByondValue::new_str(format!(
        "data:image/png;base64,{png_base64}"
    ))?)
}

#[byondapi::bind]
fn mfa_verify_code(secret: ByondValue, code: ByondValue) -> eyre::Result<ByondValue> {
    // Code MUST be a string to avoid 0 prefixing issues
    let secret_str = secret.get_string()?;
    let code_str = code.get_string()?;

    let totp = instance_totp_manager(secret_str, String::new());

    // Check provided code
    if totp.check_current(&code_str).unwrap_or(false) {
        return Ok(ByondValue::new_num(1f32));
    } else {
        return Ok(ByondValue::new_num(0f32));
    }
}
