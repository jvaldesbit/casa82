# casa82.kiware.co

Sitio de una sola página para arrendar la casa del conjunto Portal del Porvenir III
(Bosa El Porvenir, Bogotá). Tema Noche: negro con lime, los mismos tokens de
kiware.co.

No tiene backend ni base de datos. El formulario arma un mensaje de WhatsApp con
todos los datos y abre el chat con el propietario, que solo tiene que darle enviar.

## Stack

- **Astro 5** en modo estático. Una página, cero JavaScript de framework.
- **nginx** (imagen sin privilegios) sirviendo `dist/` en el puerto 8080.
- Tipografía **Geist** y **Geist Mono** desde Google Fonts.

## Desarrollo

```sh
npm install
npm run dev        # http://localhost:4321
npm run build      # genera dist/
npm run preview    # sirve dist/ para revisar el build
```

## Despliegue

Va en **GitHub Pages**. Cada push a `main` dispara
`.github/workflows/pages.yml`, que corre `astro build` y publica `dist/`.

El dominio propio sale de `public/CNAME`, que Astro copia tal cual al build.
Si ese archivo desaparece, GitHub borra el dominio propio en el siguiente
despliegue.

En Cloudflare, `casa82.kiware.co` es un **CNAME a `jvaldesbit.github.io`**.
Tiene que estar en **DNS only** (nube gris) para que GitHub pueda emitir el
certificado. Una vez emitido se puede activar el proxy, pero entonces el modo
SSL de la zona debe ser **Full**, no Flexible: con Flexible se produce un bucle
de redirecciones porque GitHub fuerza HTTPS.

### Alternativa: contenedor en Dokploy

El `Dockerfile`, el `nginx.conf` y `docker-compose.dokploy.yml` siguen en el
repo por si algún día conviene servirlo desde maia en vez de Pages. En ese caso
es una aplicación tipo Compose con el dominio apuntando al **puerto 8080**, y
hay que quitar el `CNAME` de `public/`.

Para probar ese contenedor en local:

```sh
docker compose up --build   # http://localhost:8082
```

## La miniatura de WhatsApp

`public/og.jpg` es la foto de la cocina recortada a 1200x630, y las etiquetas
Open Graph de `src/pages/index.astro` la declaran con URL absoluta. Esos dos
detalles son los que hacen que el enlace se vea con foto al compartirlo:

- Sin `site` en `astro.config.mjs`, `og:image` sale relativo y WhatsApp no
  muestra nada.
- WebP no sirve para la miniatura, tiene que ser JPEG o PNG.

WhatsApp cachea la miniatura por dominio. Si se cambia `og.jpg` y el enlace
sigue mostrando la anterior, hay que refrescarla desde el
[depurador de Facebook](https://developers.facebook.com/tools/debug/) o esperar
a que expire el caché.

## Las fotos

Los originales de WhatsApp (1200x1600 JPEG, ~4 MB en total) se convierten a WebP
a 1200px de ancho, más dos recortes del hero. Todo junto pesa ~1 MB.

```sh
# Un par por línea: <origen sin extensión> <nombre destino>
while read -r origen destino; do
  magick "$origen.jpg" -auto-orient -resize 1200x1200\> -strip -quality 72 \
    "public/fotos/$destino.webp"
done < mapa.txt

# Hero apaisado (escritorio) y vertical (móvil)
magick cocina.jpg -resize 2400x -gravity center -crop 2400x1200+0+0 +repage \
  -strip -quality 78 public/fotos/hero-ancho.webp
magick cocina.jpg -resize 1200x1600 -strip -quality 78 public/fotos/hero-alto.webp

# Miniatura de WhatsApp
magick cocina.jpg -resize 1200x -gravity center -crop 1200x630+0+0 +repage \
  -strip -quality 84 public/og.jpg
```

El orden y los pies de foto de la galería están en `src/data/fotos.js`.

El hero usa dos recortes de la misma foto porque con una sola versión vertical,
en pantallas anchas el `object-fit: cover` recortaba una franja tan estrecha que
solo se veían los azulejos del salpicadero.

## Datos que hay que tocar si cambian

| Dato | Dónde |
|---|---|
| Canon y el cálculo ingreso/canon | `CANON` en `src/pages/index.astro` |
| Número de WhatsApp | `WHATSAPP` y `WHATSAPP_VISIBLE` en `src/pages/index.astro` |
| Enlace del mapa | `MAPA` en `src/pages/index.astro` |
| Preguntas frecuentes | el arreglo de la sección `#preguntas` |
| Campos del mensaje de WhatsApp | `ETIQUETAS` en el script del final |

El canon aparece además escrito en el hero, en las preguntas frecuentes y en la
descripción de Open Graph: si sube, hay que cambiarlo en los cuatro sitios.
