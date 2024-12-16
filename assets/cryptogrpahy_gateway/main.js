import initSync, { generate_keypair, encrypt_message, decrypt_message } from "./encryption_module/cryptography_project.js";
import process from "process";
import bs58 from 'bs58'
import * as nearAPI from "near-api-js";
import Buffer from 'buffer';
import 'core-js/stable';
import 'regenerator-runtime/runtime';

window.Buffer = Buffer;
window.process = process;


function fromSecretToNearAPIJSPublicKey(secretKey) {
    const keypair = nearAPI.utils.KeyPair.fromString(secretKey);
    return bs58.encode(keypair.getPublicKey().data)
}

// async function sha256(message) {
//     const msgBuffer = new TextEncoder().encode(message);
//     const hashBuffer = await crypto.subtle.digest("SHA-256", msgBuffer);
//     const hashArray = Array.from(new Uint8Array(hashBuffer));
//     return hashArray.map(b => b.toString(16).padStart(2, "0")).join("");
// }

function signMessageForVerification(privateKey) {
    const { keyStores, KeyPair } = nearApi;
    const keyPair = KeyPair.fromString(privateKey);
    const message = new Uint8Array([]);
    const signature = keyPair.sign(message);
    const base58Signature = bs58.encode(signature.signature);
    return base58Signature;
}


window.signMessageForVerification = signMessageForVerification;

window.fromSecretToNearAPIJSPublicKey = fromSecretToNearAPIJSPublicKey;

window.generate_keypair = generate_keypair;

window.encrypt_message = encrypt_message;

window.decrypt_message = decrypt_message;

initSync().then(() => {
    console.log("Cryptography module was intied sucsessfully");
});