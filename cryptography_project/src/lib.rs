use pkcs1::{DecodeRsaPrivateKey, DecodeRsaPublicKey, EncodeRsaPrivateKey, EncodeRsaPublicKey};
use pkcs8::LineEnding;
use wasm_bindgen::prelude::*;
use rsa::*;
use rand::rngs::OsRng;
use sha1::Sha1;
use base64::{decode, encode};

#[wasm_bindgen(getter_with_clone)]
pub struct KeyPair {
    pub public_key: String,
    pub private_key: String,
}

#[wasm_bindgen]
pub fn generate_keypair() -> KeyPair  {
    let mut rng = OsRng; 
    let bits = 2048;
    let private_key = RsaPrivateKey::new(&mut rng, bits).expect("Failed to generate a key");
    let public_key = RsaPublicKey::from(&private_key);

    let public_key_pem = public_key.to_pkcs1_pem(LineEnding::LF).expect("Failed to convert public key to PEM");
    let private_key_pem = private_key.to_pkcs1_pem(LineEnding::LF).expect("Failed to convert private key to PEM");
    
    KeyPair {
        public_key: public_key_pem,
        private_key: private_key_pem.to_string(),
    }
}

#[wasm_bindgen]
pub fn encrypt_message(public_key_pem: String, message: String) -> String {
    let public_key: RsaPublicKey = RsaPublicKey::from_pkcs1_pem(&public_key_pem).expect("Incorrect Public Key");

    let message_bytes = message.as_bytes();

    let mut rng = OsRng;

    let encrypted_data = public_key
    .encrypt(&mut rng, Oaep::new::<Sha1>(), &message_bytes)
    .expect("Failed to encrypt");

    encode(encrypted_data)
}

#[wasm_bindgen]
pub fn decrypt_message(private_key_pem: String, encrypted_message_base64: String) -> String {
   let encrypted_bytes: Vec<u8> = decode(encrypted_message_base64).expect("Incorrect Public Key");
   let private_key: RsaPrivateKey = RsaPrivateKey::from_pkcs1_pem(&private_key_pem).expect("Incorrect Private Key");

   let decrypted_bytes = private_key.decrypt(Oaep::new::<Sha1>(), &encrypted_bytes).expect("Error while decrypting");

   let message_string = String::from_utf8(decrypted_bytes).expect("Invalid UTF-8");

   message_string
}