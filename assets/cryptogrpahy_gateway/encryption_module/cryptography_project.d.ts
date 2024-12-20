/* tslint:disable */
/* eslint-disable */
/**
 * @returns {KeyPair}
 */
export function generate_keypair(): KeyPair;
/**
 * @param {string} public_key_pem
 * @param {string} message
 * @returns {string}
 */
export function encrypt_message(public_key_pem: string, message: string): string;
/**
 * @param {string} private_key_pem
 * @param {string} encrypted_message_base64
 * @returns {string}
 */
export function decrypt_message(private_key_pem: string, encrypted_message_base64: string): string;
export class KeyPair {
  free(): void;
  private_key: string;
  public_key: string;
}

export type InitInput = RequestInfo | URL | Response | BufferSource | WebAssembly.Module;

export interface InitOutput {
  readonly memory: WebAssembly.Memory;
  readonly __wbg_keypair_free: (a: number, b: number) => void;
  readonly __wbg_get_keypair_public_key: (a: number) => Array;
  readonly __wbg_set_keypair_public_key: (a: number, b: number, c: number) => void;
  readonly __wbg_get_keypair_private_key: (a: number) => Array;
  readonly __wbg_set_keypair_private_key: (a: number, b: number, c: number) => void;
  readonly generate_keypair: () => number;
  readonly encrypt_message: (a: number, b: number, c: number, d: number) => Array;
  readonly decrypt_message: (a: number, b: number, c: number, d: number) => Array;
  readonly __wbindgen_export_0: WebAssembly.Table;
  readonly __wbindgen_free: (a: number, b: number, c: number) => void;
  readonly __wbindgen_malloc: (a: number, b: number) => number;
  readonly __wbindgen_realloc: (a: number, b: number, c: number, d: number) => number;
  readonly __wbindgen_exn_store: (a: number) => void;
  readonly __externref_table_alloc: () => number;
  readonly __wbindgen_start: () => void;
}

export type SyncInitInput = BufferSource | WebAssembly.Module;
/**
* Instantiates the given `module`, which can either be bytes or
* a precompiled `WebAssembly.Module`.
*
* @param {{ module: SyncInitInput }} module - Passing `SyncInitInput` directly is deprecated.
*
* @returns {InitOutput}
*/
export function initSync(module: { module: SyncInitInput } | SyncInitInput): InitOutput;

/**
* If `module_or_path` is {RequestInfo} or {URL}, makes a request and
* for everything else, calls `WebAssembly.instantiate` directly.
*
* @param {{ module_or_path: InitInput | Promise<InitInput> }} module_or_path - Passing `InitInput` directly is deprecated.
*
* @returns {Promise<InitOutput>}
*/
export default function __wbg_init (module_or_path?: { module_or_path: InitInput | Promise<InitInput> } | InitInput | Promise<InitInput>): Promise<InitOutput>;
