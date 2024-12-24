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

function decryptMessageProxy(privateKey, encryptedMessage) {
    console.log("privateKey type: ", typeof privateKey);
    console.log("encryptedMessage type: ", typeof encryptedMessage);

    if (typeof privateKey === 'object') {
        console.log("privateKey is an object");
        if (Array.isArray(privateKey)) {
            console.log("privateKey is an array");
        } else {
            console.log("privateKey is an object");
        }
    }

    console.log("privateKey value: ", privateKey);
    console.log("encryptedMessage value: ", encryptedMessage);

    let res;
    try {
        res = decrypt_message(privateKey, encryptedMessage);
        console.log("Decryption Result: ", res);
    } catch (error) {
        console.error("Error during decryption: ", error);
        res = null;
    }

    return res;
}

function encryptionProxy(dataFromDart){
    const parsedData = JSON.parse(dataFromDart);
    const public_key = parsedData['public_key']
    const message = parsedData['message']
    console.log("encryptionProxy  parsedData :: {}",parsedData);
    return encrypt_message(public_key,message);
}

function decryptionProxy(dataFromDart){
    const parsedData = JSON.parse(dataFromDart);
    const private_key = parsedData['private_key']
    const encrypted_message_base64 = parsedData['encrypted_message_base64']
    console.log("decryptionProxy  parsedData :: {}",parsedData);

    return decrypt_message(private_key,encrypted_message_base64);

}


window.signMessageForVerification = signMessageForVerification;

window.fromSecretToNearAPIJSPublicKey = fromSecretToNearAPIJSPublicKey;

window.generate_keypair = generateKeyPairProxy;

window.encrypt_message = encryptionProxy;

window.decrypt_message = decryptionProxy;

initSync().then(() => {
    console.log("Cryptography module was intied sucsessfully");
});

// navigator.mediaDevices.getUserMedia({ audio: true })
//     .then(stream => {
//         const audioContext = new AudioContext();
//         const source = audioContext.createMediaStreamSource(stream);
//         const processor = audioContext.createScriptProcessor(1024, 1, 1);

//         source.connect(processor);
//         processor.connect(audioContext.destination);

//         processor.onaudioprocess = (audioEvent) => {
//             const inputBuffer = audioEvent.inputBuffer;
//             const inputData = inputBuffer.getChannelData(0); // Float32Array of audio data
//             console.log('Real-time audio data:', inputData);
//         };
//     })
//     .catch(error => {
//         console.error('Error capturing audio:', error);
//     });
