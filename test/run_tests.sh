#!/bin/bash

# Скрипт для запуска тестов CoffeeBook

echo "Запуск тестов для CoffeeBook..."

# Проверяем, установлен ли Flutter
if ! command -v flutter &> /dev/null
then
    echo "Flutter не найден. Пожалуйста, установите Flutter."
    exit 1
fi

# Генерация моков (если есть аннотации @GenerateMocks)
echo "Генерация моков..."
flutter pub run build_runner build --delete-conflicting-outputs

# Запуск тестов
echo "Запуск тестов..."
flutter test test/user_model_test.dart test/product_model_test.dart test/product_provider_test.dart

echo "Тесты завершены!"