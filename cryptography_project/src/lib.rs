use secp256k1::{SecretKey, PublicKey, Message, sign, verify};
use wasm_bindgen::prelude::*;
use rand::rngs::OsRng;

#[wasm_bindgen]
pub struct KeyPair {
    pub public_key: String,
    pub private_key: String,
}

#[wasm_bindgen]
pub fn generate_keypair() -> KeyPair {
    let mut rng = OsRng;
    let private_key = SecretKey::new(&mut rng);
    let public_key = PublicKey::from_secret_key(&private_key);

    KeyPair {
        public_key: hex::encode(public_key.serialize()),
        private_key: hex::encode(private_key.secret_bytes()),
    }
}

#[wasm_bindgen]
pub fn sign_message(private_key: &str, message: &str) -> String {
    let private_key_bytes = hex::decode(private_key).expect("Invalid private key");
    let secret_key = SecretKey::from_slice(&private_key_bytes).expect("Invalid secret key");
    let msg = Message::from_slice(message.as_bytes()).expect("Message creation failed");

    let (signature, _) = sign(&msg, &secret_key);
    hex::encode(signature.serialize_compact())
}

#[wasm_bindgen]
pub fn verify_signature(public_key: &str, message: &str, signature: &str) -> bool {
    let public_key_bytes = hex::decode(public_key).expect("Invalid public key");
    let signature_bytes = hex::decode(signature).expect("Invalid signature");

    let public_key = PublicKey::from_slice(&public_key_bytes).expect("Invalid public key");
    let msg = Message::from_slice(message.as_bytes()).expect("Message creation failed");
    let signature = secp256k1::Signature::from_compact(&signature_bytes).expect("Invalid signature");

    verify(&msg, &signature, &public_key)
}

#[wasm_bindgen]
pub fn encrypt(public_key: &str, message: &str) -> String {
    // ECC-based encryption can be implemented via hybrid methods like ECDH + AES
    // This is a placeholder for the full implementation
    format!("Encrypted data with pubkey {}", public_key)
}

#[wasm_bindgen]
pub fn decrypt(private_key: &str, encrypted_message: &str) -> String {
    // ECC-based decryption to be implemented
    format!("Decrypted data with privkey {}", private_key)
}
