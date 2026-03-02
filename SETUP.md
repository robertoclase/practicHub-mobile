# 🚀 Guía de Setup - PracticHub Mobile

Sigue estos pasos en orden para configurar y ejecutar el proyecto completo.

## ✅ Pasos de Configuración

### 1️⃣ Instalar Dependencias Flutter

Abre una terminal en la carpeta del proyecto móvil:

```bash
cd practicHub-mobile
flutter pub get
```

**Resultado esperado:** Verás mensajes indicando que se descargaron todos los paquetes (flutter_bloc, http, shared_preferences, etc.)

---

### 2️⃣ Configurar Base de Datos (Laravel)

Navega a la carpeta de la API:

```bash
cd ../practicHub-api
```

#### Aplicar Migraciones y Seeders

Este comando creará todas las tablas y datos de prueba:

```bash
php artisan migrate:fresh --seed
```

**Datos creados:**
- ✅ 1 Admin
- ✅ 3 Alumnos (Juan, María, Carlos)
- ✅ 2 Profesores (Ana, Pedro)
- ✅ 3 Empresas (TechSolutions, WebDesign, DataAnalytics)
- ✅ 3 Seguimientos de prácticas
- ✅ 6 Partes diarios
- ✅ 3 Valoraciones

---

### 3️⃣ Iniciar Servidor Laravel

En la carpeta `practicHub-api`, ejecuta:

```bash
php artisan serve
```

**Resultado esperado:**
```
Starting Laravel development server: http://127.0.0.1:8000
```

⚠️ **IMPORTANTE:** Deja esta terminal abierta mientras uses la app móvil.

---

### 4️⃣ Ejecutar App Flutter

Abre una **nueva terminal** y navega a la carpeta móvil:

```bash
cd practicHub-mobile
```

#### Opción A: En Emulador Android

1. Abre Android Studio
2. Inicia un AVD (Android Virtual Device)
3. Ejecuta:

```bash
flutter run
```

#### Opción B: En Dispositivo Físico

1. Activa **Depuración USB** en tu dispositivo Android
2. Conecta el dispositivo por USB
3. Verifica que se detecta:

```bash
flutter devices
```

4. **IMPORTANTE:** Modifica la URL de la API en `lib/core/config/api_config.dart`:

```dart
// De esto:
static const String baseUrl = 'http://10.0.2.2:8000/api';

// A esto (reemplaza con tu IP local):
static const String baseUrl = 'http://192.168.1.XXX:8000/api';
```

Para saber tu IP local:
- **Windows:** `ipconfig` (busca IPv4)
- **macOS/Linux:** `ifconfig` o `ip addr`

5. Ejecuta:

```bash
flutter run
```

---

## 🧪 Probar la Aplicación

### Login como Alumno

1. En la pantalla de login, asegúrate de tener seleccionado **"Usuario"** (no Empresa)
2. Introduce:
   - **Email:** `juan@alumno.com`
   - **Password:** `password`
3. Pulsa **"Iniciar Sesión"**

**Resultado esperado:** Deberías ver el Dashboard con:
- Mensaje de bienvenida: "Hola, Juan Pérez"
- Chip mostrando rol: "alumno"
- Bottom navigation bar con 4 opciones

### Login como Profesor

1. En login, selecciona **"Usuario"**
2. Introduce:
   - **Email:** `ana@profesor.com`
   - **Password:** `password`
3. Pulsa **"Iniciar Sesión"**

**Resultado esperado:** Dashboard con rol "profesor" y 4 opciones en el menú inferior.

### Login como Empresa

1. En login, selecciona **"Empresa"** (importante!)
2. Introduce:
   - **Email:** `contacto@techsolutions.com`
   - **Password:** `password`
3. Pulsa **"Iniciar Sesión"**

**Resultado esperado:** Dashboard con nombre de empresa "TechSolutions S.L." y 3 opciones en el menú.

### Probar Registro

1. En login, pulsa **"Crear nueva cuenta"**
2. Introduce:
   - **Nombre:** Tu nombre
   - **Email:** tumail@test.com
   - **Contraseña:** test1234
   - **Confirmar:** test1234
   - **Rol:** Selecciona "Alumno" o "Profesor"
3. Pulsa **"Registrarse"**

**Resultado esperado:** Redirección al login con mensaje de éxito.

### Probar Logout

1. En el Dashboard, pulsa el botón rojo **"Cerrar Sesión"**
2. Confirma en el diálogo
3. Deberías volver a la pantalla de login

---

## 🔍 Verificar Comunicación con API

### Logs del Servidor Laravel

En la terminal donde ejecutaste `php artisan serve`, deberías ver requests cuando uses la app:

```
[200] POST /api/login
[200] GET /api/user
```

### Logs de Flutter

En la terminal de `flutter run`, presiona:
- **`r`** → Hot reload (recarga parcial)
- **`R`** → Hot restart (reinicia la app completa)
- **`q`** → Salir

Para ver logs completos:

```bash
flutter logs
```

---

## 📂 Estructura Final del Proyecto

```
PIDAM/
├── practicHub-api/          # Backend Laravel
│   ├── app/
│   │   ├── Http/
│   │   │   ├── Controllers/
│   │   │   │   ├── AlumnoController.php       ✅ Nuevo
│   │   │   │   ├── ProfesorAuthController.php ✅ Nuevo
│   │   │   │   └── EmpresaAuthController.php  ✅ Nuevo
│   │   │   └── Middleware/
│   │   │       └── CheckRole.php              ✅ Nuevo
│   │   └── Models/
│   │       ├── User.php                       ✅ Modificado
│   │       └── Empresa.php                    ✅ Modificado
│   └── database/
│       ├── migrations/
│       │   ├── ..._add_role_to_users_table.php      ✅ Nuevo
│       │   └── ..._add_password_to_empresas_table.php ✅ Nuevo
│       └── seeders/
│           └── DatabaseSeeder.php             ✅ Modificado
│
├── practicHub-web/          # Frontend Angular (NO TOCADO)
│
└── practicHub-mobile/       # App Flutter
    ├── lib/
    │   ├── core/           ✅ Todo nuevo
    │   │   ├── config/
    │   │   ├── models/
    │   │   ├── services/
    │   │   ├── utils/
    │   │   └── theme/
    │   ├── features/       ✅ Todo nuevo
    │   │   ├── auth/
    │   │   └── dashboard/
    │   ├── widgets/        ✅ Todo nuevo
    │   └── main.dart       ✅ Modificado
    ├── android/
    │   └── app/src/main/
    │       └── AndroidManifest.xml ✅ Modificado (permisos)
    └── pubspec.yaml        ✅ Modificado (dependencias)
```

---

## 🐛 Solución de Problemas Comunes

### Error: "Connection refused" o "Failed to connect"

**Causa:** La app no puede conectar con el servidor Laravel.

**Solución:**
1. Verifica que el servidor Laravel esté corriendo
2. Si usas dispositivo físico, asegúrate de haber cambiado la URL en `api_config.dart`
3. Comprueba que el dispositivo y el PC estén en la misma red WiFi

### Error: "Target of URI doesn't exist"

**Causa:** No se ejecutó `flutter pub get`.

**Solución:**
```bash
flutter pub get
```

### Error: "SQLSTATE[42S02]: Base table or view not found"

**Causa:** Las migraciones no se ejecutaron.

**Solución:**
```bash
cd practicHub-api
php artisan migrate:fresh --seed
```

### La app se queda en blanco después del login

**Causa:** El servidor Laravel no está respondiendo o hay un error en la API.

**Solución:**
1. Revisa la terminal de `php artisan serve` para ver errores
2. En Flutter, presiona `R` (hot restart completo)
3. Verifica que el servidor devuelva el campo `role` en `/api/user`

### Error: "Incorrect email or password"

**Causa:** Estás intentando hacer login como empresa usando el selector "Usuario" o viceversa.

**Solución:**
- Para alumnos/profesores → selecciona **"Usuario"**
- Para empresas → selecciona **"Empresa"**

---

## 📊 Endpoints de la API

### Autenticación
```
POST /api/register          - Registro de usuarios
POST /api/login             - Login usuarios (alumnos/profesores)
POST /api/empresa/login     - Login empresas
POST /api/logout            - Cerrar sesión
GET  /api/user              - Datos del usuario autenticado
```

### Alumnos (requiere token + role=alumno)
```
GET /api/alumno/mis-practicas                    - Mis seguimientos
GET /api/alumno/practica/{id}                    - Detalle de práctica
GET /api/alumno/mis-partes                       - Todos mis partes
GET /api/alumno/practica/{id}/partes             - Partes de una práctica
GET /api/alumno/mis-valoraciones                 - Mis valoraciones
```

### Profesores (requiere token + role=profesor)
```
GET  /api/profesor/mis-seguimientos              - Seguimientos de mis alumnos
GET  /api/profesor/mis-alumnos                   - Lista de alumnos
GET  /api/profesor/partes-pendientes             - Partes sin validar
POST /api/profesor/partes/{id}/validar           - Validar parte
POST /api/profesor/valoraciones                  - Crear valoración
```

### Empresas (requiere token de empresa)
```
GET  /api/empresa/mis-alumnos                    - Alumnos en prácticas
GET  /api/empresa/seguimientos/{id}              - Detalle seguimiento
GET  /api/empresa/partes-pendientes              - Partes sin validar
POST /api/empresa/partes/{id}/validar            - Validar parte
```

### Público
```
GET /api/empresas/listado                        - Lista de empresas (para búsqueda)
```

---

## 📈 Próximos Pasos

Una vez verificado que auth y dashboard funcionan:

1. **Feature Seguimientos** → Ver listado de prácticas
2. **Feature Partes Diarios** → Crear y validar partes
3. **Feature Empresas** → Búsqueda y detalle
4. **Feature Valoraciones** → Ver y crear valoraciones
5. **Navegación Completa** → Conectar bottom nav con pantallas

---

## 💡 Tips de Desarrollo

### Hot Reload vs Hot Restart

- **`r`** (hot reload): Rápido, mantiene el estado, usa para cambios de UI
- **`R`** (hot restart): Lento, reinicia app, usa para cambios en BLoC o servicios

### Ver logs en tiempo real

```bash
flutter logs --clear
```

### Debuggear en Chrome (web)

```bash
flutter run -d chrome
```

### Generar APK de release

```bash
flutter build apk --release
```

El APK estará en: `build/app/outputs/flutter-apk/app-release.apk`

---

✅ **¡Listo!** Ahora deberías tener el proyecto funcionando completamente.

Si encuentras problemas, revisa los logs de ambas terminales (Laravel y Flutter).
