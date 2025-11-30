import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './'),
    },
  },
  css: {
    postcss: {
      plugins: [],
    },
  },
  build: {
    outDir: 'dist',
    sourcemap: false,
    minify: false,
    target: 'esnext',
    rollupOptions: {
      output: {
        manualChunks: undefined,
        inlineDynamicImports: false,
      },
    },
    chunkSizeWarningLimit: 50000,
  },
  server: {
    port: 5173,
    host: true,
    hmr: false,
    watch: {
      usePolling: true,
    },
  },
  optimizeDeps: {
    exclude: [],
  },
})