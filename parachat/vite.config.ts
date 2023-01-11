import legacy from '@vitejs/plugin-legacy';
import react from '@vitejs/plugin-react';
import path from 'path';
import { defineConfig } from 'vite';

// https://vitejs.dev/config/
export default defineConfig({
  root: path.join(__dirname, 'src'),
  base: '',
  resolve: {
    alias: {
      '~': path.resolve(__dirname, './src'),
    },
  },
  plugins: [
    react(),
    legacy({
      targets: ['IE >= 11'],
    }),
  ],
  build: {
    outDir: path.join(__dirname, 'dist'),
    emptyOutDir: true,
    assetsDir: '',
    manifest: true,
    rollupOptions: {
      output: {
        assetFileNames: 'parachat-[name][extname]',
        entryFileNames: 'parachat-[name].js',
      },
    },
  },
});
