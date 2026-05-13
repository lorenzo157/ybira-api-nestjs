# Estrategia de Base de Datos

## Archivos SQL del proyecto

```
sql_files/
├── create_database.sql   # Esquema completo (tablas, constraints, indexes, triggers)
└── seed.sql              # Datos iniciales (roles, provincias, ciudades, usuario admin)
```

## Migraciones con TypeORM

Las migraciones permiten modificar la base de datos de forma controlada y reversible.
Los archivos se generan en la carpeta `migrations/` en la raíz del proyecto.

### Comandos disponibles

```bash
# Generar migración automáticamente desde cambios en entidades
npm run migration:generate -- migrations/NombreDescriptivo

# Crear archivo de migración vacío (para escribir SQL manualmente)
npm run migration:create -- migrations/NombreDescriptivo

# Ejecutar migraciones pendientes
npm run migration:run

# Deshacer la última migración ejecutada
npm run migration:revert
```

### Cómo funciona el tracking

TypeORM crea una tabla `migrations` en la base de datos donde registra cada migración ejecutada:

```
id | timestamp         | name
---+-------------------+----------------------------------
 1 | 1778438672518     | AddNickNameToUsers1778438672518
```

Al ejecutar `migration:run`, TypeORM compara los archivos en `migrations/` con
la tabla y ejecuta solo las que aún no fueron aplicadas, en orden cronológico.

### Flujo de trabajo recomendado

Se prefiere `migration:create` sobre `migration:generate` porque este proyecto usa
nombres de constraints personalizados (`fk_tree`, `fk_project`, etc.) que no siguen
la convención de TypeORM. El generate produce cientos de líneas de ruido que requieren
limpieza manual. Con create, el SQL es explícito y sin sorpresas.

```
1. Crear el archivo vacío
   npm run migration:create -- migrations/NombreDescriptivo
   → genera migrations/17XXXXXXXXXX-NombreDescriptivo.ts
         ↓
2. Escribir el SQL en up() y su inverso en down()
         ↓
3. Actualizar la entidad TypeScript correspondiente en src/
         ↓
4. npm run migration:run
```

**Ejemplo de migración manual:**

```typescript
export class AddNickNameToUsers1778438672518 implements MigrationInterface {
    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "users" ADD "nick_name" character varying(100)`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "nick_name"`);
    }
}
```

### Configuración actual (database.provider.ts)

```typescript
synchronize: false,  // NUNCA true en producción — TypeORM modificaría la DB sin control
migrationsRun: true, // Ejecuta migraciones pendientes automáticamente al arrancar la app
migrations: [__dirname + '/../../migrations/**/*.js'], // Lee archivos compilados
```

## Migraciones en producción

En producción **no se ejecutan migraciones manualmente**. La app las detecta y aplica
automáticamente al arrancar gracias a `migrationsRun: true`.

### Flujo de deploy

```
Desarrollador (local):
  1. npm run migration:create -- migrations/NombreDescriptivo
  2. Escribir SQL en up() y down()
  3. Actualizar la entidad TypeScript
  4. git commit + git push
         ↓
Servidor de producción:
  5. git pull                  ← baja el código nuevo + el archivo de migración
  6. npm run build             ← compila src/ y migrations/ a dist/
  7. pm2 restart ybira-api     ← al arrancar, TypeORM detecta la migración nueva
                                  y la ejecuta automáticamente contra la DB
```

### Por qué funciona así

- El archivo de migración viaja en git junto con el código
- La tabla `migrations` en producción no tiene registrada esa migración
- TypeORM la detecta como pendiente y la ejecuta antes de levantar la API
- Es el mismo comportamiento que tenías con Docker — solo que lo dispara el arranque de la app en vez del contenedor

### En caso de error en producción

Si una migración falla al arrancar, la app no levanta. Para revertir:

```bash
npm run migration:revert   # desde el servidor, deshace la última migración
pm2 restart ybira-api
```

## Buenas prácticas

1. **Nunca usar `synchronize: true` en producción**
2. **Preferir `migration:create`** sobre `migration:generate` — escribir el SQL manualmente evita el ruido de constraints que genera automáticamente TypeORM
3. **Hacer backup antes de migrar** en producción
4. **Probar en staging primero**
5. **Migraciones pequeñas y enfocadas** — un cambio por migración
6. **No eliminar archivos de migraciones** — son el historial de cambios de la DB
