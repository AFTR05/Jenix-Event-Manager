# 🔐 Sistema de Auto-Login - Alexander von Humboldt Event Manager

## 📋 Resumen

El sistema de auto-login permite que los usuarios permanezcan autenticados entre sesiones de la aplicación sin necesidad de ingresar sus credenciales cada vez que abren la app.

---

## 🏗️ Arquitectura

### Componentes Principales:

1. **SplashScreen** (`splash_screen.dart`)
   - Pantalla inicial que se muestra al abrir la app
   - Verifica si hay una sesión guardada
   - Redirige automáticamente a Home o Login

2. **AuthenticationController** (`authentication_controller.dart`)
   - Gestiona el guardado/recuperación de sesiones
   - Usa SharedPreferences para persistencia
   - Implementa refresh de tokens

3. **LoginProvider** (`login_provider.dart`)
   - Estado global del usuario en memoria
   - Accesible desde toda la app con Riverpod

4. **SharedPreferences**
   - Almacenamiento local persistente
   - Guarda UserEntity como JSON
   - Mantiene flag de "Remember Me"

---

## 🔄 Flujo de Autenticación

### 1. **Login por Primera Vez**

```
Usuario → LoginScreen → AuthenticationController.logIn()
                           ↓
                   Guarda en memoria (loginProvider)
                           ↓
                   Guarda en disco (SharedPreferences)
                           ↓
                   Navega a Home
```

### 2. **Registro por Primera Vez**

```
Usuario → RegisterScreen → AuthenticationController.register()
                              ↓
                      Guarda en memoria (loginProvider)
                              ↓
                      Guarda en disco (SharedPreferences)
                              ↓
                      Navega a Home
```

### 3. **Inicio de App con Sesión Guardada**

```
App inicia → SplashScreen → AuthenticationController.isLoggedUser()
                                ↓
                        Lee SharedPreferences
                                ↓
                        ¿Hay datos guardados?
                          ↙         ↘
                      SÍ             NO
                       ↓              ↓
            Intenta refresh token   Login
                       ↓
              ¿Refresh exitoso?
                 ↙        ↘
               SÍ          NO
                ↓           ↓
     Actualiza tokens    Usa datos guardados
                ↓           ↓
        Carga en memoria ────┘
                ↓
            Navega a Home
```

### 4. **Logout**

```
Usuario → ProfileMenu → "Cerrar Sesión" → AuthenticationController.logOut()
                                              ↓
                                     Llama API logout
                                              ↓
                                     Limpia SharedPreferences
                                              ↓
                                     Limpia loginProvider
                                              ↓
                                     Navega a Login
```

---

## 💾 Datos Almacenados

### En SharedPreferences:

```json
{
  "remember_me": true,
  "user_data": "{\"email\":\"user@example.com\",\"name\":\"John Doe\",\"phone\":\"+573001234567\",\"role\":\"student\",\"accessToken\":\"eyJhbG...\",\"refreshToken\":\"eyJhbG...\"}"
}
```

### En Memoria (LoginProvider):

```dart
UserEntity(
  email: 'user@example.com',
  name: 'John Doe',
  phone: '+573001234567',
  role: 'student',
  accessToken: 'eyJhbG...',
  refreshToken: 'eyJhbG...',
)
```

---

## 🔑 Métodos Clave

### AuthenticationController

#### `logIn(email, password, rememberMe)`
- Autentica con el servidor
- Guarda en loginProvider
- Si `rememberMe == true`, guarda en SharedPreferences
- Retorna `Either<Failure, UserEntity>`

#### `register(email, password, name, phone, role, rememberMe)`
- Registra nuevo usuario
- Guarda automáticamente la sesión
- Retorna `Either<Failure, UserEntity>`

#### `isLoggedUser()`
- Lee flag `remember_me` de SharedPreferences
- Si es `false`, retorna `false`
- Si es `true`, lee `user_data`
- Intenta refresh token si existe `refreshToken`
- Si refresh falla, usa datos guardados como fallback
- Carga usuario en loginProvider
- Retorna `bool`

#### `logOut()`
- Llama a la API de logout
- Limpia SharedPreferences (`remember_me`, `user_data`)
- Limpia loginProvider (setState(null))
- Retorna `Either<Failure, bool>`

#### `refreshToken(refreshToken)`
- Obtiene nuevos tokens del servidor
- Actualiza loginProvider
- Actualiza SharedPreferences
- Retorna `Either<Failure, UserEntity>`

---

## 🎯 Casos de Uso

### ✅ Usuario quiere permanecer autenticado

```dart
// En login_screen.dart
await authController.logIn(
  email: emailController.text,
  password: passwordController.text,
  rememberMe: true, // ← Importante!
);
```

### ✅ Usuario NO quiere permanecer autenticado

```dart
await authController.logIn(
  email: emailController.text,
  password: passwordController.text,
  rememberMe: false, // ← Session volátil
);
```

### ✅ Verificar si hay usuario autenticado

```dart
final authController = ref.read(authenticationControllerProvider);
final isLogged = await authController.isLoggedUser();

if (isLogged) {
  // Usuario tiene sesión activa
  Navigator.pushReplacementNamed(context, RoutesApp.home);
} else {
  // No hay sesión
  Navigator.pushReplacementNamed(context, RoutesApp.login);
}
```

### ✅ Obtener usuario actual

```dart
// Desde cualquier widget con Riverpod
final user = ref.watch(loginProviderProvider);

if (user != null) {
  print('Usuario: ${user.name}');
  print('Email: ${user.email}');
  print('Role: ${user.role}');
}
```

### ✅ Cerrar sesión

```dart
final authController = ref.read(authenticationControllerProvider);
final result = await authController.logOut();

result.fold(
  (failure) => print('Error: ${failure.message}'),
  (success) => print('Sesión cerrada correctamente'),
);
```

---

## 🛡️ Seguridad

### ✅ Implementado:

1. **Tokens en SharedPreferences**: 
   - Los tokens se guardan localmente
   - SharedPreferences es específico por app y usuario del dispositivo

2. **Refresh de tokens**:
   - Si el accessToken expira, se usa refreshToken
   - Evita que el usuario tenga que volver a loguearse

3. **Fallback seguro**:
   - Si refresh falla, usa datos guardados
   - Si datos guardados están corruptos, limpia y va a login

4. **Limpieza completa en logout**:
   - Llama API de logout
   - Limpia SharedPreferences
   - Limpia memoria (loginProvider)

### ⚠️ Consideraciones:

1. **SharedPreferences NO es cifrado**:
   - Los datos se guardan en texto plano
   - Para mayor seguridad, considera usar `flutter_secure_storage`

2. **Tokens expuestos**:
   - Si alguien accede al dispositivo, puede leer los tokens
   - Implementa biometría para capa adicional de seguridad

3. **Refresh token infinito**:
   - Considera expiración de refresh tokens
   - Fuerza re-login después de cierto tiempo (ej: 30 días)

---

## 📱 Pantallas

### SplashScreen
- **Ruta**: `/` (inicial)
- **Duración**: ~2 segundos
- **Funciones**:
  - Animación de logo
  - Verifica sesión
  - Redirige a Home o Login

### LoginScreen
- **Ruta**: `/login`
- **Funciones**:
  - Login con email/password
  - Checkbox "Recordarme" (por defecto: true)
  - Navegación a Register

### RegisterScreen
- **Ruta**: `/register`
- **Funciones**:
  - Registro de nuevo usuario
  - Auto-login después de registro exitoso
  - Remember me: true por defecto

### ProfileScreen
- **Ruta**: `/home` → Tab Profile
- **Funciones**:
  - Muestra info del usuario
  - Switch de tema
  - Menú con opciones
  - Botón "Cerrar Sesión"

---

## 🚀 Testing

### Probar Auto-Login:

1. **Hacer login con "Recordarme" activado**:
   ```
   - Abrir app
   - Ingresar credenciales
   - Marcar "Recordarme"
   - Hacer login
   - ✅ Debe ir a Home
   ```

2. **Cerrar y reabrir la app**:
   ```
   - Cerrar completamente la app (stop debugging)
   - Volver a ejecutar
   - ✅ Debe mostrar SplashScreen
   - ✅ Debe ir directo a Home (sin pedir login)
   ```

3. **Verificar datos persistentes**:
   ```
   - En Home → Profile
   - ✅ Debe mostrar nombre del usuario
   - ✅ Debe mostrar email
   - ✅ Debe mostrar role badge
   ```

4. **Hacer logout**:
   ```
   - Profile → Cerrar Sesión
   - Confirmar
   - ✅ Debe ir a LoginScreen
   - ✅ Debe limpiar datos
   ```

5. **Reabrir después de logout**:
   ```
   - Cerrar app
   - Volver a ejecutar
   - ✅ Debe mostrar SplashScreen
   - ✅ Debe ir a LoginScreen (NO a Home)
   ```

---

## 🔧 Troubleshooting

### Problema: "Siempre me pide login"

**Posibles causas**:
1. `rememberMe` está en `false`
2. SharedPreferences no se está guardando
3. Datos corruptos en SharedPreferences

**Solución**:
```dart
// Verificar en login_screen.dart que rememberMe esté en true
await authController.logIn(
  email: emailController.text,
  password: passwordController.text,
  rememberMe: true, // ← Debe ser true
);
```

### Problema: "App se cuelga en SplashScreen"

**Posibles causas**:
1. Error en isLoggedUser()
2. refreshToken inválido causa bucle
3. API de refresh no responde

**Solución**:
```dart
// En splash_screen.dart, agregar timeout:
try {
  final isLogged = await authController
      .isLoggedUser()
      .timeout(const Duration(seconds: 5));
} on TimeoutException {
  // Forzar ir a login si toma mucho tiempo
  Navigator.pushReplacementNamed(context, RoutesApp.login);
}
```

### Problema: "Usuario incorrecto después de reabrir"

**Posibles causas**:
1. Datos corruptos en SharedPreferences
2. refresh token devuelve usuario diferente

**Solución**:
```dart
// Limpiar manualmente SharedPreferences
final prefs = await SharedPreferences.getInstance();
await prefs.clear();
```

---

## 📊 Diagrama de Estados

```
┌─────────────┐
│ App Inicia  │
└──────┬──────┘
       │
       v
┌─────────────┐
│SplashScreen │
└──────┬──────┘
       │
       v
  ¿Hay sesión guardada?
       │
   ┌───┴───┐
   │       │
  SÍ       NO
   │       │
   v       v
[Home]  [Login] ←──────┐
   │       │           │
   │       v           │
   │   ¿Login exitoso? │
   │       │           │
   │      SÍ           │
   │       ├───────────┘
   │       │
   v       v
┌─────────────┐
│    Home     │
└──────┬──────┘
       │
       v
  ¿Logout?
       │
      SÍ
       │
       v
   [Login]
```

---

## ✅ Checklist de Implementación

- [x] SplashScreen creada con animaciones
- [x] AuthenticationController.isLoggedUser() implementado
- [x] Guardado de UserEntity en SharedPreferences
- [x] Refresh de tokens automático
- [x] Rutas actualizadas (SplashScreen como inicial)
- [x] ProfileMenu con logout funcional
- [x] Manejo de errores en logout
- [x] LoginScreen con rememberMe
- [x] RegisterScreen con auto-login
- [x] Limpieza de sesión en logout

---

## 📝 Notas Finales

1. **Remember Me por defecto**: Actualmente está en `true` tanto en login como registro. Si quieres dar opción al usuario, agrega un checkbox en `login_screen.dart`.

2. **Duración de splash**: 2 segundos es óptimo. Ajusta en `_checkSession()` si necesitas más/menos tiempo.

3. **Seguridad**: Para apps de producción, considera `flutter_secure_storage` en lugar de SharedPreferences.

4. **Tokens expirados**: El sistema intenta refresh automático. Si falla, usa datos guardados como fallback.

5. **Múltiples dispositivos**: Cada dispositivo mantiene su propia sesión. Logout en un dispositivo no afecta otros.

---

**Desarrollado para**: Alexander von Humboldt Event Manager  
**Fecha**: Octubre 2025  
**Framework**: Flutter + Riverpod + SharedPreferences
