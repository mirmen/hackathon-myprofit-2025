-- Migration: Add sample events data
-- Description: Add sample events for testing the recommended events feature

-- First, we need to get some club IDs to reference
-- This is just for testing purposes - in a real application, events would be created by club admins

-- Sample events for book clubs
INSERT INTO events (club_id, title, description, date_time, location, event_type)
SELECT id, 'Мастер-класс по латте-арту', 'Научитесь создавать красивые узоры на кофе', '2025-10-15 14:00:00+00', 'Кофейня "Уют"', 'workshop'
FROM clubs WHERE type = 'coffee' LIMIT 1;

INSERT INTO events (club_id, title, description, date_time, location, event_type)
SELECT id, 'Обсуждение "1984" Оруэлла', 'Глубокое обсуждение классической антиутопии', '2025-10-10 18:00:00+00', 'Читальный зал', 'meeting'
FROM clubs WHERE type = 'book' LIMIT 1;

INSERT INTO events (club_id, title, description, date_time, location, event_type)
SELECT id, 'Конкурс на лучшую книжную полку', 'Покажите нам вашу самую красивую книжную полку', '2025-10-20 12:00:00+00', 'Онлайн', 'competition'
FROM clubs WHERE type = 'book' LIMIT 1;

INSERT INTO events (club_id, title, description, date_time, location, event_type)
SELECT id, 'Дегустация новых сортов кофе', 'Попробуйте наши новинки из Колумбии и Эфиопии', '2025-10-12 16:00:00+00', 'Кофейня "Уют"', 'meeting'
FROM clubs WHERE type = 'coffee' LIMIT 1;