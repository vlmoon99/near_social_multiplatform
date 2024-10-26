use rsa::{Pkcs1v15Encrypt, RsaPrivateKey, RsaPublicKey};
use wasm_bindgen::prelude::*;

// lifted from the `console_log` example
#[wasm_bindgen]
extern "C" {
    #[wasm_bindgen(js_namespace = console)]
    fn log(s: &str);
}


#[wasm_bindgen(start)]
fn run() {
    log("Hello, World!");
}

fn encode_base64(data: &[u8]) -> String {
    base64::encode(data)
}

fn decode_base64(encoded_str: &str) -> Result<Vec<u8>, base64::DecodeError> {
    base64::decode(encoded_str)
}

#[wasm_bindgen]
pub fn test() -> u8 {
    let mut rng = rand::thread_rng();
    let bits = 2048;
    let priv_key = RsaPrivateKey::new(&mut rng, bits).expect("failed to generate a key");
    let pub_key = RsaPublicKey::from(&priv_key);
    
    let data = b"hello world";
    let enc_data = pub_key.encrypt(&mut rng, Pkcs1v15Encrypt, &data[..]).expect("failed to encrypt");
    assert_ne!(&data[..], &enc_data[..]);

    // Encode encrypted data for logging
    let encoded_enc_data = encode_base64(&enc_data);
    log(&format!("Encrypted Data (Base64): {}", encoded_enc_data));

    let dec_data = priv_key.decrypt(Pkcs1v15Encrypt, &enc_data).expect("failed to decrypt");
    assert_eq!(&data[..], &dec_data[..]);

    // Encode decrypted data for logging
    let encoded_dec_data = encode_base64(&dec_data);
    log(&format!("Decrypted Data (Base64): {}", encoded_dec_data));

    // Example of decoding back to binary (not necessary for just logging)
    // let decoded_data = decode_base64(&encoded_dec_data).expect("Failed to decode");
    // assert_eq!(&data[..], &decoded_data[..]);

    return 1;
}