# PracticHub Mobile 📱

Aplicación móvil Flutter para la gestión de prácticas empresariales. Interfaz para alumnos, profesores y empresas del sistema PracticHub.

## 🏗️ Arquitectura

El proyecto sigue **Clean Architecture** con separación de responsabilidades:

```
lib/
├── core/                    # Funcionalidad compartida
│   ├── config/             # Configuración API
│   ├── models/             # Modelos de datos
│   ├── services/           # Servicios (API, Auth, Storage)
│   ├── utils/              # Utilidades (validators, formatters)
│   └── theme/              # Tema de la app
├── features/               # Módulos por funcionalidad
│   ├── auth/              # Autenticación
│   │   ├── bloc/          # Estado con BLoC
│   │   └── ui/            # Pantallas
│   └── dashboard/         # Panel principal
└── widgets/               # Widgets reutilizables
```

## 🚀 Configuración Inicial

### 1. Instalar dependencias Flutter

```bash
cd practicHub-mobile
flutter pub get
```

### 2. Configurar y ejecutar API (Laravel)

```bash
cd ../practicHub-api

# Ejecutar migraciones y seeders (crea datos de prueba)
php artisan migrate:fresh --seed

# Iniciar servidor en puerto 8000
php artisan serve
```

### 3. Ejecutar app móvil

```bash
cd ../practicHub-mobile

# Abrir emulador Android o conectar dispositivo físico
flutter run
```

## 🔐 Credenciales de Prueba

El seeder crea usuarios de todos los roles:

### 👨‍💼 Administrador
- **Email:** admin@practichub.com
- **Password:** password

### 👨‍🎓 Alumnos
- **Email:** juan@alumno.com | maria@alumno.com | carlos@alumno.com
- **Password:** password

### 👨‍🏫 Profesores
- **Email:** ana@profesor.com | pedro@profesor.com
- **Password:** password

### 🏢 Empresas
- **Email:** contacto@techsolutions.com
- **Password:** password
- **Email:** info@webdesign.com
- **Password:** password
- **Email:** contacto@dataanalytics.com
- **Password:** password

## 🛠️ Tecnologías

- **Flutter:** 3.10.7
- **Gestión de estado:** flutter_bloc ^8.1.6
- **HTTP Client:** http ^1.2.0
- **Almacenamiento local:** shared_preferences ^2.2.2
- **Utilidades:** equatable ^2.0.5, intl ^0.19.0

## 📡 Configuración API

La URL base de la API se configura en `lib/core/config/api_config.dart`:

```dart
static const String baseUrl = 'http://10.0.2.2:8000/api';
```

**Nota:** `10.0.2.2` es la IP del localhost desde el emulador de Android.

Para dispositivo físico, usa tu IP local:
```dart
static const String baseUrl = 'http://192.168.1.XXX:8000/api';
```

## 👥 Roles y Funcionalidades

### Alumno
- ✅ Ver mis prácticas (seguimientos)
- ✅ Gestionar partes diarios
- ✅ Consultar valoraciones
- ✅ Buscar empresas

### Profesor
- ✅ Ver alumnos asignados
- ✅ Validar partes diarios
- ✅ Crear valoraciones
- ✅ Gestionar seguimientos

### Empresa
- ✅ Ver alumnos en prácticas
- ✅ Validar partes diarios
- ✅ Consultar seguimientos

## 📱 Estado del Proyecto

### ✅ Completado
- [x] Autenticación (login, registro, logout)
- [x] Dashboard con navegación por roles
- [x] Servicios API completos
- [x] Modelos de datos
- [x] Widgets reutilizables
- [x] Tema personalizado

### 🚧 Pendiente
- [ ] Feature Seguimientos (lista y detalle)
- [ ] Feature Partes Diarios (CRUD completo)
- [ ] Feature Empresas (búsqueda y detalle)
- [ ] Feature Valoraciones (ver y crear)
- [ ] Navegación completa entre pantallas
- [ ] Manejo de errores avanzado

## 🎨 Tema

Colores principales:
- **Primary:** #6C63FF (Púrpura)
- **Secondary:** #4CAF50 (Verde)
- **Error:** #F44336 (Rojo)

## 📝 Notas de Desarrollo

- Este es un proyecto MVP para un alumno de 2º DAM
- Enfocado en funcionalidad sobre diseño avanzado
- Sigue el patrón del repositorio: [flutter_tmdb](https://github.com/miguelcamposedu/pmdm/tree/master/04_Flutter/flutter_tmdb/lib)
- La interfaz web (Angular) es para administradores
- La interfaz móvil es para usuarios finales (alumnos, profesores, empresas)

## 🐛 Troubleshooting

### Error de conexión API
- Verifica que el servidor Laravel esté corriendo: `php artisan serve`
- Comprueba la URL en `api_config.dart`
- En dispositivo físico, usa tu IP local en lugar de `10.0.2.2`

### Widgets no se muestran
- Ejecuta `flutter clean && flutter pub get`
- Reinicia la app: `r` en la terminal o `R` (hot restart)

### Errores de build
- Verifica versión de Flutter: `flutter doctor`
- Limpia caché: `flutter clean`
- Reinstala dependencias: `flutter pub get`

## 📖 Recursos

- [Documentación Flutter](https://docs.flutter.dev/)
- [BLoC Pattern](https://bloclibrary.dev/)
- [Laravel Sanctum](https://laravel.com/docs/sanctum)

---

**Autor:** Estudiante 2º DAM  
**Curso:** 2024-2025  
**Proyecto:** Sistema de gestión de prácticas empresariales

