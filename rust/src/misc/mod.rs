use base64::{prelude::BASE64_STANDARD, Engine};
use byondapi::value::ByondValue;
use ed25519_dalek::{Signer, SigningKey};
use eyre::eyre;
use uuid::Uuid;
use zeroize::Zeroize;

const ED25519_SECRET_KEY_LEN: usize = 32;

#[byondapi::bind]
fn misc_new_uuid() -> eyre::Result<ByondValue> {
    let uuid: String = Uuid::new_v4().to_string();
    Ok(ByondValue::new_str(uuid)?)
}

#[byondapi::bind]
fn misc_unix_timestamp() -> eyre::Result<ByondValue> {
    let ts = format!(
        "{:.6}",
        std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_secs_f64()
    );

    Ok(ByondValue::new_str(ts)?)
}

#[byondapi::bind]
fn misc_ed25519_sign(secret_key: ByondValue, message: ByondValue) -> eyre::Result<ByondValue> {
    let key_str = secret_key.get_string()?;
    let msg_bytes = &message.get_string()?.into_bytes();

    // Decode the signing key
    let mut decoded = BASE64_STANDARD.decode(key_str)?;
    let actual = decoded.len();
    if actual != ED25519_SECRET_KEY_LEN {
        decoded.zeroize();
        return Err(eyre!(format!(
            "Invalid key length - expected {}, actual {}",
            ED25519_SECRET_KEY_LEN, actual
        )));
    }

    let mut secret_key = [0u8; ED25519_SECRET_KEY_LEN];
    secret_key.copy_from_slice(&decoded);
    decoded.zeroize();

    let signing_key = SigningKey::from_bytes(&secret_key);
    secret_key.zeroize();

    // Now actually sign the bloody thing
    let signature = signing_key.sign(msg_bytes);

    // And send it back to byond
    Ok(ByondValue::new_str(
        BASE64_STANDARD.encode(signature.to_bytes()),
    )?)
}
