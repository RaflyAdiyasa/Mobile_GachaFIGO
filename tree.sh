#!/bin/bash

echo "Membuat struktur direktori dan file di dalam lib/ ..."

# Buat direktori
mkdir -p lib/models
mkdir -p lib/pages
mkdir -p lib/widgets

# Buat file kosong
touch lib/main.dart

# Models
touch lib/models/user.dart
touch lib/models/user.g.dart
touch lib/models/card.dart
touch lib/models/card.g.dart

# Pages
touch lib/pages/login_page.dart
touch lib/pages/register_page.dart
touch lib/pages/main_menu_page.dart
touch lib/pages/gacha_page.dart
touch lib/pages/collection_page.dart
touch lib/pages/topup_page.dart

echo "Struktur lib/ berhasil dibuat."

