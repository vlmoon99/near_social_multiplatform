import { defineConfig } from "vite";
import babel from "vite-plugin-babel";
import { nodePolyfills } from "vite-plugin-node-polyfills";
import topLevelAwait from "vite-plugin-top-level-await";
import wasm from "vite-plugin-wasm";
import { nodeModulesPolyfillPlugin } from 'esbuild-plugins-node-modules-polyfill';

export default defineConfig({
  base: "./",
  plugins: [
    babel(),
    nodePolyfills(),
    wasm(),
    topLevelAwait(),
  ],
  build: {
    rollupOptions: {
      output: {
        entryFileNames: "bundle.js",
        chunkFileNames: "bundle.js",
        assetFileNames: "[name][extname]",
      }
    },
  },
  server: {
    open: "/index.html",
    port: 3000,
  },
  resolve: {
    alias: {
      buffer: 'buffer',
    },
  },
  optimizeDeps: {
    esbuildOptions: {
      plugins: [
        nodeModulesPolyfillPlugin({
          process: true,
          buffer: true,
        }),
      ],
    },
  },
});
