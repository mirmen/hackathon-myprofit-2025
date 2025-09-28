-- Migration: Add sample subscription plans
-- Description: Add sample subscription plans for coffee subscriptions

-- Sample subscription plans
INSERT INTO subscription_plans (title, price, cups, included_drinks, is_popular, description)
VALUES 
  ('Стандартный', '4 990 ₽', '30 чашек', '["Капучино 0.3л", "Американо 0.3л", "Эспрессо"]', false, 'Идеальный выбор для ежедневного кофе');

INSERT INTO subscription_plans (title, price, cups, included_drinks, is_popular, description)
VALUES 
  ('Премиум', '7 990 ₽', '50 чашек', '["Капучино 0.5л", "Латте 0.5л", "Американо 0.5л", "Флэт Уайт", "Мокко"]', true, 'Для настоящих ценителей кофе');

INSERT INTO subscription_plans (title, price, cups, included_drinks, is_popular, description)
VALUES 
  ('Максимальный', '9 990 ₽', '70 чашек', '["Любой кофе 0.5л", "Специальные напитки", "Десерты в подарок"]', false, 'Неограниченное удовольствие от кофе');

INSERT INTO subscription_plans (title, price, cups, included_drinks, is_popular, description)
VALUES 
  ('Студенческий', '3 490 ₽', '20 чашек', '["Капучино 0.3л", "Американо 0.3л"]', false, 'Специальное предложение для студентов');