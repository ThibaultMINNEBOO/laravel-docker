# Building Assets With Vite

Node.js and npm are installed in the development image, so [Vite](https://laravel.com/docs/vite)
runs inside the `php` container: you don't need Node.js on your host.

## Installing the Dependencies

```console
docker compose exec php npm install
```

## Starting the Dev Server

Vite must listen on all interfaces to be reachable from the host.
Add these options to the `server` section of your `vite.config.js`
(create the section if your version of the skeleton doesn't have one):

```diff
 export default defineConfig({
     plugins: [
         // ...
     ],
     server: {
+        host: '0.0.0.0',
+        port: 5173,
+        // Tell the browser where to connect for Hot Module Replacement
+        hmr: {
+            host: 'localhost',
+        },
         watch: {
             ignored: ['**/storage/framework/views/**'],
         },
     },
 });
```

Then start the dev server:

```console
docker compose exec php npm run dev
```

Port `5173` is published by `compose.override.yaml`, change it with the `VITE_PORT`
environment variable if it is already in use on your host.

> [!NOTE]
>
> If your site is served over HTTPS with a self-signed certificate, your browser
> may block the assets served by Vite over plain HTTP.
> Accept the certificate of `https://localhost` first, or run
> `npm run build` and let Laravel serve the compiled assets.

## Building for Production

The production image builds the assets for you: the `asset_builder` stage of the
`Dockerfile` runs `npm ci && npm run build`, and the result (`public/build/`) is
copied into the final image.
Nothing to do besides:

```console
docker compose -f compose.yaml -f compose.prod.yaml build --pull --no-cache
```
