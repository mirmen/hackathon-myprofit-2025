# CoffeeBook - Техническая документация

## Обзор проекта

CoffeeBook - это мобильное приложение для книжного магазина с кофейней, разработанное с использованием Flutter с Supabase в качестве бэкенд-сервиса. Приложение предоставляет пользователям возможность просматривать товары, управлять корзиной покупок, участвовать в книжных клубах и взаимодействовать с сообществом любителей книг и кофе.

## Системные требования

### Среда разработки
- Flutter SDK 3.8.1 или выше
- Dart SDK
- Android Studio или Xcode (в зависимости от целевой платформы)
- Аккаунт Supabase для бэкенд-сервисов

### Зависимости
Основные зависимости, используемые в проекте:
- provider: ^6.1.5+1 (Управление состоянием)
- supabase_flutter: ^2.10.1 (Бэкенд-сервисы)
- google_fonts: ^6.3.1 (Типографика)
- cached_network_image: ^3.3.1 (Кэширование изображений)
- shimmer: ^3.0.0 (Эффекты загрузки)
- http: ^1.2.1 (HTTP-клиент)
- shared_preferences: ^2.2.3 (Локальное хранение данных)

## Руководство по установке

### 1. Клонирование репозитория
```bash
git clone <url-репозитория>
cd coffeebook
```

### 2. Установка зависимостей
```bash
flutter pub get
```

### 3. Конфигурация Supabase
1. Создайте проект на Supabase (https://supabase.com)
2. Выполните SQL-запросы для создания необходимых таблиц
3. Скопируйте URL проекта и анонимный ключ из настроек проекта

### 4. Переменные окружения
Создайте файл `lib/.env` со следующим содержимым:
```
SUPABASE_URL=ваш_supabase_url_здесь
SUPABASE_ANON_KEY=ваш_supabase_anon_key_здесь
```

### 5. Схема базы данных
Выполните следующие SQL-запросы в редакторе SQL Supabase:

```sql
-- Таблица профилей
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  avatar_url TEXT,
  member_since TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  bonus_points INTEGER DEFAULT 0,
  bonus_points_goal INTEGER DEFAULT 1000,
  active_subscriptions TEXT[] DEFAULT '{}',
  status TEXT DEFAULT 'active',
  role TEXT DEFAULT 'user'  
);

-- Функция для обработки создания нового пользователя
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, name, email, role)
  VALUES (
    NEW.id, 
    COALESCE(NEW.raw_user_meta_data->>'name', NEW.email), 
    NEW.email,
    'user'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Триггер для автоматического создания профиля
CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- Таблица продуктов
CREATE TABLE products (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  author TEXT NOT NULL,
  type TEXT NOT NULL,
  price NUMERIC(10,2) NOT NULL,
  rating NUMERIC(3,1) DEFAULT 0.0,
  image_url TEXT,
  description TEXT,
  options TEXT[] NOT NULL,
  is_book BOOLEAN NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Таблица элементов корзины
CREATE TABLE cart_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  product_id TEXT NOT NULL REFERENCES products(id),
  title TEXT NOT NULL,
  author TEXT NOT NULL,
  type TEXT NOT NULL,
  price NUMERIC(10,2) NOT NULL,
  image_url TEXT,
  selected_option TEXT NOT NULL,
  quantity INTEGER NOT NULL DEFAULT 1,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Таблица избранного
CREATE TABLE favorites (
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  product_id TEXT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, product_id)
);

-- Таблица акций
CREATE TABLE promotions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  subtitle TEXT NOT NULL,
  description TEXT,
  image_url TEXT,
  link TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  category TEXT DEFAULT 'Акции'
);

-- Таблица клубов
CREATE TABLE clubs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  image_url TEXT,
  members_count INTEGER DEFAULT 0,
  online_count INTEGER DEFAULT 0,
  type TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Таблица участников клубов
CREATE TABLE club_members (
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, club_id)
);

-- Таблица планов подписки
CREATE TABLE subscription_plans (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  price TEXT NOT NULL,
  cups TEXT NOT NULL,
  included_drinks TEXT[] NOT NULL,
  is_popular BOOLEAN DEFAULT FALSE,
  description TEXT
);
```

### 6. Запуск приложения
```bash
flutter run
```

## Архитектура проекта

### Структура папок
```
lib/
├── main.dart                 # Точка входа
├── models/                   # Модели данных
├── providers/                # Провайдеры управления состоянием
├── screens/                  # Экраны приложения
├── utils/                    # Вспомогательные функции и утилиты
├── widgets/                  # Переиспользуемые виджеты
└── theme/                    # Тема приложения и стилизация
```

### Управление состоянием
Приложение использует пакет Provider для управления состоянием. Каждая основная функция имеет свой собственный провайдер:

- AuthProvider: Аутентификация пользователей
- CartProvider: Управление корзиной покупок
- FavoritesProvider: Управление избранными товарами
- ProductProvider: Каталог товаров
- PromotionsProvider: Рекламные материалы
- ClubsProvider: Книжные и кофейные клубы
- UserProvider: Данные профиля пользователя
- BookExchangeProvider: Функциональность обмена книгами
- ReadingChallengesProvider: Читательские челленджи
- AdminProvider: Административные функции

### Модели данных
Приложение использует следующие модели данных:

- Product: Представляет книги, кофе и десерты
- User: Информация о профиле пользователя
- Club: Книжные и кофейные клубы
- Promotion: Рекламные материалы
- CartItem: Товары в корзине покупок
- Subscription: Планы подписки
- ReadingChallenge: Читательские челленджи
- BookExchange: Элементы обмена книгами

## Основные функции

### Аутентификация пользователей
Система аутентификации использует сервис Supabase Auth:
- Регистрация пользователей
- Вход/выход пользователей
- Управление сессиями
- Контроль доступа на основе ролей

### Каталог товаров
Каталог товаров поддерживает:
- Просмотр товаров по категориям
- Поиск товаров
- Просмотр деталей товара
- Добавление товаров в корзину

### Корзина покупок
Функциональность корзины включает:
- Добавление/удаление товаров
- Обновление количества
- Расчет итоговой суммы
- Постоянное хранение

### Избранное
Пользователи могут:
- Добавлять товары в избранное
- Просматривать избранные товары
- Удалять товары из избранного

### Клубы
Функции клубов:
- Просмотр доступных клубов
- Присоединение/выход из клубов
- Просмотр деталей клуба
- Управление участниками клуба

### Профиль пользователя
Управление профилем:
- Просмотр информации о пользователе
- Отслеживание бонусных баллов
- Управление подписками
- Просмотр читательских челленджей

### Административная панель
Административные функции:
- Управление товарами
- Управление акциями
- Управление клубами
- Управление пользователями

## Интеграция API

### Интеграция с Supabase
Приложение интегрируется с Supabase для:
- Аутентификации (Supabase Auth)
- Операций с базой данных (Supabase Database)
- Обновлений в реальном времени (Supabase Realtime)
- Хранения файлов (Supabase Storage)

### Поток данных
1. Компоненты пользовательского интерфейса взаимодействуют с провайдерами
2. Провайдеры обмениваются данными с Supabase
3. Supabase возвращает данные
4. Провайдеры обновляют состояние
5. Компоненты пользовательского интерфейса перестраиваются с новыми данными

## Тестирование

### Модульное тестирование
Модульные тесты должны охватывать:
- Сериализацию/десериализацию моделей
- Логику провайдеров
- Вспомогательные функции

### Интеграционное тестирование
Интеграционные тесты должны проверять:
- Потоки аутентификации
- Получение и хранение данных
- Навигацию между экранами

### Тестирование виджетов
Тесты виджетов должны обеспечивать:
- Правильное отображение компонентов пользовательского интерфейса
- Работу пользовательских взаимодействий
- Корректное отражение изменений состояния

## Развертывание

### Сборка для релиза
```bash
flutter build apk        # Android
flutter build ios        # iOS
flutter build web        # Web
```

### Конфигурация среды
Убедитесь, что переменные окружения правильно настроены для продакшена:
- SUPABASE_URL
- SUPABASE_ANON_KEY

## Устранение неполадок

### Распространенные проблемы

#### Ошибки подключения к Supabase
- Проверьте переменные окружения в файле .env
- Проверьте статус проекта Supabase
- Убедитесь в наличии сетевого подключения

#### Сбои аутентификации
- Проверьте настройки аутентификации Supabase
- Проверьте подтверждение электронной почты
- Просмотрите политики аутентификации

#### Проблемы с загрузкой изображений
- Проверьте конфигурацию хранилища
- Просмотрите политики доступа
- Проверьте URL изображений

## Будущие улучшения

Планируемые улучшения:
- Расширенная функция поиска
- Система отзывов и рейтингов
- Интеграция платежей
- Push-уведомления
- Поддержка темной темы
- Многоязычная поддержка

## Поддержка

Для технической поддержки:
1. Проверьте логи в Supabase Dashboard
2. Выполните flutter doctor
3. Просмотрите консоль разработки
4. Обратитесь к этой документации