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



function urlBase64ToUint8Array(base64String) {
    var padding = '='.repeat((4 - base64String.length % 4) % 4);
    var base64 = (base64String + padding)
        .replace(/\-/g, '+')
        .replace(/_/g, '/');

    var rawData = window.atob(base64);
    var outputArray = new Uint8Array(rawData.length);

    for (var i = 0; i < rawData.length; ++i) {
        outputArray[i] = rawData.charCodeAt(i);
    }
    return outputArray;
}


window.urlBase64ToUint8Array = urlBase64ToUint8Array;

window.signMessageForVerification = signMessageForVerification;

window.fromSecretToNearAPIJSPublicKey = fromSecretToNearAPIJSPublicKey;

window.generate_keypair = generateKeyPairProxy;

window.encrypt_message = encrypt_message;

window.decrypt_message = decrypt_message;


initSync().then(() => {
    console.log("Cryptography module was intied sucsessfully");
});


