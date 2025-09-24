# hackathon-myprofit-2025
# Региональный этап хакатона «Моя профессия – ИТ» 2025
# CoffeeBook - Flutter App с Supabase

Приложение книжного магазина с кофейней, разработанное на Flutter с использованием Supabase в качестве backend.

## Возможности

- 📚 Каталог книг, кофе и десертов
- 🛒 Корзина покупок
- ❤️ Избранные товары  
- 👥 Книжные и кофейные клубы
- 📰 Новости и акции
- 👤 Профиль пользователя с бонусной системой
- 🔐 Аутентификация пользователей

## Настройка проекта

### 1. Установка зависимостей

```bash
flutter pub get
```

### 2. Настройка Supabase

1. Создайте проект в [Supabase](https://supabase.com)
2. Выполните SQL-запросы из комментария в коде для создания таблиц
3. Скопируйте URL и анонимный ключ из настроек проекта

### 3. Настройка переменных окружения

Отредактируйте файл `lib/.env`:

```env
SUPABASE_URL=your_supabase_project_url_here
SUPABASE_ANON_KEY=your_supabase_anon_key_here
```

### 4. Создание таблиц в Supabase

Выполните следующие SQL-запросы в SQL Editor вашего Supabase проекта:

```sql
-- Создание таблиц
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  avatar_url TEXT,
  member_since TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  bonus_points INTEGER DEFAULT 0,
  bonus_points_goal INTEGER DEFAULT 1000,
  active_subscriptions TEXT[] DEFAULT '{}',
  status TEXT DEFAULT 'active'
);

-- Функция создания профиля при регистрации
CREATE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, name, email)
  VALUES (NEW.id, NEW.raw_user_meta_data->>'name' OR NEW.email, NEW.email);
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

-- Корзина
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

-- Избранное
CREATE TABLE favorites (
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  product_id TEXT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, product_id)
);

-- Акции
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

-- Клубы
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

-- Участники клубов
CREATE TABLE club_members (
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, club_id)
);

-- Подписки
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

### 5. Добавление тестовых данных

```sql
-- Тестовые продукты
INSERT INTO products (id, title, author, type, price, rating, image_url, description, options, is_book)
VALUES
  ('1', 'Искусство заваривания кофе', 'Джеймс Хоффман', 'Книга', 890.0, 4.8, 'https://images.pexels.com/photos/1907785/pexels-photo-1907785.jpeg', 'Захватывающая книга о мире кофе', '{"Твёрдый переплёт", "Мягкий переплёт", "Электронная"}', true),
  ('2', 'Эфиопия Иргачиф', 'Свежая обжарка', 'Кофе', 650.0, 4.7, 'https://images.pexels.com/photos/1031750/pexels-photo-1031750.jpeg', 'Идеальный напиток для утреннего чтения', '{"Маленький (100г)", "Стандарт (250г)", "Большой (500г)"}', false),
  ('3', 'Круассан с миндалем', 'Домашняя выпечка', 'Десерт', 190.0, 4.9, 'https://images.pexels.com/photos/1653877/pexels-photo-1653877.jpeg', 'Свежая выпечка к вашему любимому кофе', '{"1 шт", "2 шт", "6 шт"}', false);

-- Тестовые акции
INSERT INTO promotions (title, subtitle, description, image_url, category)
VALUES
  ('Скидка 25% на всю фантастику', 'До конца октября', 'Только до конца октября! Приходите за новинками и классикой жанра.', 'https://images.pexels.com/photos/1907785/pexels-photo-1907785.jpeg', 'Акции'),
  ('Вечер с автором', '25 сентября в 19:00', 'Презентация новой книги и автограф-сессия.', 'https://images.pexels.com/photos/159711/books-bookstore-book-reading-159711.jpeg', 'События');

-- Тестовые клубы
INSERT INTO clubs (title, description, image_url, members_count, online_count, type)
VALUES
  ('Книжный клуб "Фантастика"', 'Обсуждаем Азимова, Лема и других мэтров жанра', 'https://images.pexels.com/photos/1370298/pexels-photo-1370298.jpeg', 247, 23, 'book'),
  ('Сообщество бариста', 'Делимся рецептами и техниками приготовления кофе', 'https://images.pexels.com/photos/302899/pexels-photo-302899.jpeg', 189, 15, 'coffee');
```

### 6. Настройка RLS (Row Level Security)

```sql
-- Включение RLS и создание политик безопасности
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;

-- Политики доступа
CREATE POLICY profile_select ON profiles FOR SELECT TO authenticated
USING (id = auth.uid());

CREATE POLICY profile_update ON profiles FOR UPDATE TO authenticated
USING (id = auth.uid());

CREATE POLICY cart_select ON cart_items FOR SELECT TO authenticated
USING (user_id = auth.uid());

CREATE POLICY cart_insert ON cart_items FOR INSERT TO authenticated
WITH CHECK (user_id = auth.uid());

CREATE POLICY cart_update ON cart_items FOR UPDATE TO authenticated
USING (user_id = auth.uid());

CREATE POLICY cart_delete ON cart_items FOR DELETE TO authenticated
USING (user_id = auth.uid());

CREATE POLICY favorites_select ON favorites FOR SELECT TO authenticated
USING (user_id = auth.uid());

CREATE POLICY favorites_insert ON favorites FOR INSERT TO authenticated
WITH CHECK (user_id = auth.uid());

CREATE POLICY favorites_delete ON favorites FOR DELETE TO authenticated
USING (user_id = auth.uid());

-- Публичный доступ к каталогу
CREATE POLICY products_select ON products FOR SELECT TO anon USING (true);
CREATE POLICY promotions_select ON promotions FOR SELECT TO anon USING (true);
CREATE POLICY clubs_select ON clubs FOR SELECT TO anon USING (true);
```

## Запуск приложения

```bash
flutter run
```

## Архитектура

Приложение использует:
- **Provider** для управления состоянием
- **Supabase** для backend и аутентификации
- **Google Fonts** для типографики
- **Cached Network Image** для кэширования изображений
- **Shimmer** для эффектов загрузки

## Структура проекта

```
lib/
├── main.dart                 # Точка входа
├── models/                   # Модели данных
├── providers/                # Provider'ы для состояния
├── screens/                  # Экраны приложения
├── services/                 # Сервисы
├── utils/                    # Утилиты и константы
├── widgets/                  # Переиспользуемые виджеты
└── theme/                    # Тема приложения
```

## Тестирование

Для тестирования убедитесь, что:

1. ✅ Supabase проект настроен корректно
2. ✅ Все таблицы созданы
3. ✅ RLS политики настроены
4. ✅ Тестовые данные добавлены
5. ✅ Переменные окружения заполнены

## Возможные проблемы

**Ошибка подключения к Supabase:**
- Проверьте URL и ключ в `.env` файле
- Убедитесь, что проект Supabase активен

**Ошибки аутентификации:**
- Проверьте настройки аутентификации в Supabase
- Убедитесь, что email подтвержден

**Проблемы с изображениями:**
- Настройте Storage bucket в Supabase
- Проверьте политики доступа к Storage

## Поддержка

При возникновении проблем проверьте:
1. Логи в Supabase Dashboard
2. Flutter Doctor output
3. Консоль разработчика

Приложение готово к работе! 🚀