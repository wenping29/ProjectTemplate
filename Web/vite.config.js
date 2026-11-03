import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';
import path from 'node:path';
export default defineConfig({
    plugins: [vue()],
    resolve: {
        alias: { '@': path.resolve(__dirname, 'src') },
    },
    server: {
        port: 5174,
        proxy: {
            '/api': {
                target: 'https://localhost:5001',
                changeOrigin: true,
            },
        },
    },
});
