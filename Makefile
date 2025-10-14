# 🚀 EZSolutions - Comandos rápidos para EZManagement (Flutter)

# 🧹 Limpia el proyecto y obtiene dependencias
clean:
	flutter clean
	flutter pub get

# 🏗️ Compila la app (.aab)
build:
	flutter build appbundle

# ▶️ Ejecuta la app en modo desarrollo
run:
	flutter run

# 🧪 Corre los tests
test:
	flutter test

# 🌍 Genera traducciones
tr:
	dart run easy_localization:generate -S assets/translations -O lib/translations
	dart run easy_localization:generate -S assets/translations -O lib/translations -o locale_keys.g.dart -f keys

# 🌍 Genera traducciones con FVM
trfvm:
	fvm dart run easy_localization:generate -S assets/translations -O lib/translations
	fvm dart run easy_localization:generate -S assets/translations -O lib/translations -o locale_keys.g.dart -f keys

# 🔍 Analiza el código
check:
	flutter analyze

# 🔁 Código reactivo (watch)
watch:
	dart run build_runner watch -d

# 🔁 Watch con FVM
watchfvm:
	fvm dart run build_runner watch -d

# ⚙️ Genera código una vez
gen:
	dart run build_runner build -d

# ⚙️ Genera con FVM
genfvm:
	fvm dart run build_runner build -d

# 🚀 Compilación para producción
prod:
	flutter build appbundle --release --flavor prod

# 🧼 Limpieza profunda (Pods, lock, etc.)
deep:
	flutter clean && \
	cd ios && rm -rf Pods Podfile.lock && cd .. && \
	flutter pub get && \
	cd ios && pod install && cd ..

# 🔥 Limpia caché de gradle
gradle:
	rm -rf ~/.gradle/caches/*

# 🧽 Borra archivos .g.dart generados
gclean:
	find . -type f -name '*.g.dart' -delete

# 🐞 Ejecuta con logs detallados
log:
	flutter run -v

# 🚀 Ejecuta en modo release
rel:
	flutter run --release
