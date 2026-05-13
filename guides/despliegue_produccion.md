# Guía de Despliegue en Producción — ybira API

## Requisitos del servidor

| Tecnología     | Versión mínima |
|----------------|----------------|
| SO             | Debian         |
| Node.js        | 24 LTS         |
| PostgreSQL      | 18.x           |
| PostGIS        | 3.x (extensión de PostgreSQL) |
| npm            | incluido con Node.js |

---

## 1. Clonar el repositorio
```bash
git clone https://github.com/lorenzo157/ybira-api-nestjs /opt/ybira-api
cd /opt/ybira-api
```

## 2. Instalar dependencias
```bash
npm install --omit=dev
```

## 3. Configurar variables de entorno
Crear el archivo `.env` en la raíz del proyecto:

```bash
nano .env
```

Contenido del archivo `.env` para producción:

```env
DATABASE_APPLICATION_HOST=localhost
DATABASE_APPLICATION_PORT=5432
DATABASE_APPLICATION_DATABASE=ybira
DATABASE_APPLICATION_USERNAME=postgres
DATABASE_APPLICATION_PASSWORD=<contraseña-segura>
DATABASE_APPLICATION_SCHEMA=public
S3_ACCESS_KEY=
S3_SECRET_ACCESS_KEY=
S3_BUCKET=
S3_REGION=
NODE_ENV=production

SECRET=<cadena-aleatoria-larga>
PASSWORD_PEPPER=<cadena-aleatoria-larga>

FILE_STORAGE_TYPE=local
LOCAL_STORAGE_PATH=./uploads/
BASE_URL=https://api.ybira.municipalidadsf.unl.edu.ar

ALLOWED_ORIGINS=https://app.ybira.municipalidadsf.unl.edu.ar
```

> Si se utiliza almacenamiento en AWS S3, cambiar `FILE_STORAGE_TYPE=local` por `FILE_STORAGE_TYPE=s3` y completar las credenciales correspondientes.

> **Importante:** Los valores de `SECRET` y `PASSWORD_PEPPER` deben ser cadenas largas y aleatorias. Se pueden generar con:
> ```bash
> node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
> ```

## 4. Crear la base de datos

Conectarse a PostgreSQL y ejecutar:

```sql
CREATE DATABASE ybira;
\c ybira
CREATE EXTENSION IF NOT EXISTS postgis;
```

Luego ejecutar los scripts SQL en este orden:

```bash
psql -U postgres -d ybira -f sql_files/create_database.sql
psql -U postgres -d ybira -f sql_files/seed.sql
```
---
## 5. Compilar la aplicación

```bash
npm run build
```
Esto genera la carpeta `dist/` con el código compilado listo para producción.

---
## 6. Iniciar la aplicación

### Inicio manual (para verificar que funciona)

```bash
npm run start:prod
```

La API quedará disponible en el puerto **3000**.

### Inicio automático con PM2 (recomendado para producción)

Instalar PM2 globalmente:

```bash
npm install -g pm2
```

Iniciar la aplicación:

```bash
pm2 start dist/main.js --name ybira-api
```
Configurar inicio automático al reiniciar el servidor:
```bash
pm2 startup
```
> **Importante:** Si el servidor se reinicia, PM2 no arranca solo — y la aplicación queda caída hasta que alguien lo inicie manualmente. El comando `pm2 startup` soluciona eso registrando PM2 como servicio del sistema, para que arranque automáticamente en cada reinicio.
>
> Sin embargo, `pm2 startup` **no hace el registro por sí solo**: imprime en la terminal un comando personalizado para tu servidor que debés copiar y ejecutar manualmente. Ese comando se ve similar a esto (no uses este, usa el que apareció en tu terminal):
> ```bash
> sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u myuser --hp /home/myuser
> ```
> Una vez ejecutado ese comando, guardá la lista de procesos actuales de PM2 para que se restauren automáticamente tras cada reinicio:
```bash
pm2 save
```
Comandos útiles de PM2:
```bash
pm2 status              # ver estado
pm2 logs ybira-api      # ver logs en tiempo real
pm2 restart ybira-api   # reiniciar
pm2 stop ybira-api      # detener
```
---
## 7. Verificar el despliegue

Probar que la API responde:

```bash
curl https://api.ybira.municipalidadsf.unl.edu.ar/api
```
Debe responder con la documentación Swagger o devolver el HTML correspondiente.
---
## 8. Actualización de la aplicación

Cuando haya una nueva versión:

```bash
cd /opt/ybira-api
git pull
npm install --omit=dev
npm run build
pm2 restart ybira-api
```
---

## Despliegue de la Aplicación Web (Frontend)

### Requisitos adicionales

| Tecnología | Versión mínima |
|------------|----------------|
| Node.js    | 24 LTS         |
| npm        | incluido con Node.js |

---

### 1. Clonar el repositorio del frontend
```bash
git clone https://github.com/lorenzo157/ybira-web-react /opt/ybira-web
cd /opt/ybira-web
```

### 2. Instalar dependencias
```bash
npm install
```

### 3. Configurar variables de entorno
Crear el archivo `.env` en la raíz del proyecto frontend:

```bash
nano .env
```

Contenido del archivo `.env` para producción:

```env
PORT=3001
REACT_APP_BASE_URL=https://api.ybira.municipalidadsf.unl.edu.ar
```

### 4. Compilar la aplicación
```bash
npm run build
```
Esto genera la carpeta `build/` con los archivos estáticos listos para producción.

### 5. Iniciar la aplicación con PM2

```bash
npm install -g serve
pm2 start "serve -s build -l 3001" --name ybira-web
```

Configurar inicio automático al reiniciar el servidor:
```bash
pm2 startup
```
> **Importante:** Si el servidor se reinicia, PM2 no arranca solo — y la aplicación queda caída hasta que alguien lo inicie manualmente. El comando `pm2 startup` soluciona eso registrando PM2 como servicio del sistema, para que arranque automáticamente en cada reinicio.
>
> Sin embargo, `pm2 startup` **no hace el registro por sí solo**: imprime en la terminal un comando personalizado para tu servidor que debés copiar y ejecutar manualmente. Ese comando se ve similar a esto (no uses este, usa el que apareció en tu terminal):
> ```bash
> sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u myuser --hp /home/myuser
> ```
> Una vez ejecutado ese comando, guardá la lista de procesos actuales de PM2 para que se restauren automáticamente tras cada reinicio:
```bash
pm2 save
```

### 6. Verificar el despliegue

> **Nota:** Se asume que existe un reverse proxy (por ejemplo Nginx) configurado para redirigir HTTPS al puerto 3001.

```bash
curl https://app.ybira.municipalidadsf.unl.edu.ar
```

### Actualización del frontend

```bash
cd /opt/ybira-web
git pull
npm install
npm run build
pm2 restart ybira-web
```

---

## Notas adicionales
- Los logs de la API se pueden consultar con `pm2 logs ybira-api`.
- Los logs del frontend se pueden consultar con `pm2 logs ybira-web`.
- El directorio `uploads/trees_photos` **no** debe eliminarse al actualizar — contiene las fotos de los árboles.
- El archivo `.env` **no** se incluye en el repositorio y debe crearse manualmente en cada servidor.
- La documentación Swagger de la API está disponible en `https://api.ybira.municipalidadsf.unl.edu.ar/api`.
- La aplicación web está disponible en `https://app.ybira.municipalidadsf.unl.edu.ar`.