// @ts-check
import { defineConfig } from 'astro/config';

// `site` es lo que hace que las URLs absolutas de Open Graph salgan bien: sin
// esto WhatsApp recibe una ruta relativa en og:image y no muestra miniatura.
export default defineConfig({
  site: 'https://casa82.kiware.co',
  build: {
    // Archivos planos (`/gracias.html` en vez de `/gracias/index.html`) para que
    // nginx los sirva sin reglas de reescritura.
    format: 'file',
  },
});
