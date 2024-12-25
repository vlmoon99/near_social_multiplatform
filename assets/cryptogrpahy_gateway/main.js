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

function signMessageForVerification(privateKey) {
    const { KeyPair } = nearAPI;
    const keyPair = KeyPair.fromString(privateKey);
    const message = new Uint8Array([]);
    const signature = keyPair.sign(message);

    const base58Signature = bs58.encode(signature.signature);
    return base58Signature;
}

function generateKeyPairProxy() {
    let keys = generate_keypair();
    return JSON.stringify({ "private_key": keys.private_key, "public_key": keys.public_key });
}

// function encryptionProxy(public_key,message){
//     return encrypt_message(public_key,message);
// }

// function decryptionProxy(private_key,encrypted_message_base64){
//     return decrypt_message(private_key,encrypted_message_base64);

// }


window.signMessageForVerification = signMessageForVerification;

window.fromSecretToNearAPIJSPublicKey = fromSecretToNearAPIJSPublicKey;

window.generate_keypair = generateKeyPairProxy;

window.encrypt_message = encrypt_message;

window.decrypt_message = decrypt_message;

initSync().then(() => {
    console.log("Cryptography module was intied sucsessfully");
});


navigator.serviceWorker.register('push-notification-service-worker.js');
