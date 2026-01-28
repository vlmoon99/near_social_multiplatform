# Отчёт по анализу централизованных сервисов

**Проект:** Near Social Multiplatform
**Версия:** 1.0.7
**Дата анализа:** 27 января 2026
**Цель:** Подготовка к децентрализации приложения

---

## Содержание

1. [Общая картина](#1-общая-картина)
2. [Supabase (Критично)](#2-supabase-критично)
3. [Firebase (Отключён)](#3-firebase-отключён)
4. [Push Notifications (Не реализовано)](#4-push-notifications-не-реализовано)
5. [WebSocket (Экспериментально)](#5-websocket-экспериментально)
6. [NEAR Blockchain (Оставляем)](#6-near-blockchain-оставляем)
7. [План удаления](#7-план-удаления)
8. [Критические последствия](#8-критические-последствия)
9. [Рекомендации по децентрализации](#9-рекомендации-по-децентрализации)

---

## 1. Общая картина

| Сервис | Статус | Влияние удаления |
|--------|--------|------------------|
| **Supabase** | Активен | КРИТИЧНО |
| **Firebase** | Отключён | Без влияния |
| **Push Notifications** | Не реализовано | Без влияния |
| **WebSocket (звонки)** | Экспериментально | Среднее |
| **NEAR Blockchain** | Активен | НЕ УДАЛЯЕМ |

---

## 2. Supabase (Критично)

### 2.1 Зависимость

**Файл:** `pubspec.yaml`
```yaml
supabase_flutter: ^2.12.0
```

### 2.2 Конфигурация

**Файл:** `lib/config/constants.dart` (строки 43-54)

```dart
class SystemsManagmentConstans {
  static const String mainSystemLink =
      "https://5dfd-178-54-185-162.ngrok-free.app/";
  static const String mainSystemAnonKey =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...";

  static const String secondarySystemLink =
      "https://af48-178-54-185-162.ngrok-free.app/";
  static const String secondarySystemAnonKey =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...";
}
```

### 2.3 Инициализация

**Файл:** `lib/main.dart` (строки 14, 19-22)

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    url: SystemsManagmentConstans.mainSystemLink,
    anonKey: SystemsManagmentConstans.mainSystemAnonKey,
  );
  // ...
}
```

### 2.4 Затронутые функции

#### Аутентификация

| Функция | Файл | Строки | Описание |
|---------|------|--------|----------|
| Анонимная авторизация | `lib/modules/vms/core/auth_controller.dart` | 79-80 | `signInAnonymously()` для получения UUID |
| Верификация аккаунта | `lib/modules/vms/core/auth_controller.dart` | 161-174 | Edge function `verifyAccount` |
| Logout | `lib/modules/vms/core/auth_controller.dart` | 108, 252 | `auth.signOut()` |
| Logout (UI) | `lib/modules/home/pages/settings/settings_page.dart` | 22-39 | Выход из аккаунта |

#### Система чатов

| Функция | Файл | Строки | Описание |
|---------|------|--------|----------|
| Стриминг сообщений | `lib/modules/home/pages/chat/chat_page.dart` | 49-57 | Real-time подписка на таблицу Message |
| Стриминг чатов | `lib/modules/home/pages/chat/widgets/chat_list_body.dart` | 35-37 | Real-time подписка на таблицу Chat |
| Получение ключей шифрования | `lib/modules/home/pages/chat/chat_page.dart` | 131-135 | Запрос к таблице User |
| Создание чата | `lib/modules/home/vms/chats/user_chats_page_controller.dart` | 55-62 | Edge function `chat_creation` |
| Удаление чата | `lib/modules/home/vms/chats/user_chats_page_controller.dart` | 102-109 | Edge function `delete_chat` |
| Отправка сообщения | `lib/modules/home/vms/chats/chat_page_controller.dart` | 8-15 | Edge function `add_message_to_the_chat` |
| Удаление сообщения | `lib/modules/home/vms/chats/chat_page_controller.dart` | 28-35 | Edge function `delete_message_from_the_chat` |

### 2.5 Edge Functions

| Функция | Путь | Назначение |
|---------|------|-----------|
| `verifyAccount` | `supabase/functions/verifyAccount/index.ts` | Верификация NEAR подписи, создание сессии, управление пользователями |
| `chat_creation` | `supabase/functions/chat_creation/index.ts` | Создание/восстановление чатов, валидация сессии |
| `add_message_to_the_chat` | `supabase/functions/add_message_to_the_chat/index.ts` | Добавление зашифрованных сообщений |
| `delete_message_from_the_chat` | `supabase/functions/delete_message_from_the_chat/index.ts` | Пометка сообщений как удалённых |
| `delete_chat` | `supabase/functions/delete_chat/index.ts` | Soft delete чатов |

### 2.6 Схема базы данных

**Файл:** `supabase/db_setup/migration_db_query.sql`

```sql
-- Таблица пользователей
User (
  id UUID PRIMARY KEY,
  public_key TEXT,           -- Ключ шифрования
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  is_banned BOOLEAN
)

-- Таблица чатов
Chat (
  id UUID PRIMARY KEY,
  metadata JSONB,            -- Участники, статус удаления
  created_at TIMESTAMP,
  updated_at TIMESTAMP
)

-- Таблица сообщений
Message (
  id UUID PRIMARY KEY,
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  message_type TEXT,
  message JSONB,             -- Зашифрованное содержимое
  delete JSONB,
  chat_id UUID REFERENCES Chat,
  author_id UUID REFERENCES User
)

-- Таблица сессий
Session (
  user_id UUID,
  account_id TEXT,           -- NEAR account ID
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  is_active BOOLEAN
)
```

### 2.7 Потери при удалении Supabase

| Функционал | Критичность | Описание |
|------------|-------------|----------|
| Система чатов | КРИТИЧНО | Real-time сообщения, история переписки полностью перестанут работать |
| Верификация аккаунтов | КРИТИЧНО | Проверка подписи NEAR на сервере |
| Управление сессиями | КРИТИЧНО | Авторизация и персистентность сессий |
| Хранение ключей шифрования | КРИТИЧНО | E2E encryption ключи пользователей |
| Списки чатов | КРИТИЧНО | Real-time обновление списка чатов |

---

## 3. Firebase (Отключён)

### 3.1 Статус

Все зависимости Firebase **закомментированы** и не активны.

**Файл:** `pubspec.yaml` (строки 34-47)

```yaml
# cloud_firestore: ^5.5.1
# cloud_functions: ^4.7.6
# firebase_auth: ^5.3.4
# firebase_core: ^3.8.1
# firebase_messaging: ^15.1.6
# flutter_firebase_chat_core: ^1.6.7
```

### 3.2 Остаточный код

**Файл:** `lib/modules/vms/core/auth_controller.dart` (строки 182-249)

Содержит закомментированный код интеграции с Firebase Auth и Firestore.

### 3.3 Конфигурационные файлы

| Файл | Статус | Действие |
|------|--------|----------|
| `firebase.json` | Содержит только hosting config | Можно удалить |
| `google-services.json` | Отсутствует | - |
| `GoogleService-Info.plist` | Отсутствует | - |

### 3.4 Действие

Безопасно удалить:
- Закомментированные зависимости из `pubspec.yaml`
- Закомментированный код из `auth_controller.dart`
- Файл `firebase.json`

---

## 4. Push Notifications (Не реализовано)

### 4.1 Статус

Зависимость добавлена, но **НЕ используется** в коде.

**Файл:** `pubspec.yaml` (строка 54)

```yaml
flutter_local_notifications: ^20.0.0
```

### 4.2 Проверка использования

- Нет импортов `flutter_local_notifications` в Dart-файлах
- Нет обращений к FCM токенам
- Нет обработчиков push-уведомлений
- Нет конфигурации APNs/FCM

### 4.3 Платформенная конфигурация

| Платформа | Файл | Статус |
|-----------|------|--------|
| Android | `android/app/src/main/AndroidManifest.xml` | Нет push-конфигурации |
| iOS | `ios/Runner/Info.plist` | Нет push-конфигурации |

### 4.4 Действие

Безопасно удалить зависимость `flutter_local_notifications` из `pubspec.yaml`.

---

## 5. WebSocket (Экспериментально)

### 5.1 Реализация

**Файл:** `lib/modules/home/pages/chat/call_room_page.dart` (строки 1-104)

```dart
import 'package:web_socket_channel/web_socket_channel.dart';

final channel = WebSocketChannel.connect(
  Uri.parse('ws://localhost:8080'),  // Локальный сервер!
);

void setupWebSocketStream() async {
  channel.stream.listen((msg) {
    setState(() {
      message = msg.toString();
    });
  });

  timer = Timer.periodic(Duration(milliseconds: 50), (_) {
    channel.sink.add(jsonEncode(randomDataList));
  });
}
```

### 5.2 Зависимость

**Файл:** `pubspec.yaml` (строка 82)

```yaml
web_socket_channel: ^3.0.3
```

### 5.3 Статус

- Подключается к `localhost:8080` — не работает в продакшене
- Незавершённая реализация для голосовых/видео звонков
- Отправляет случайные данные каждые 50ms (тестовый код)

### 5.4 Действие

Рекомендуется удалить:
- Зависимость `web_socket_channel` из `pubspec.yaml`
- Файл `lib/modules/home/pages/chat/call_room_page.dart` или отключить функционал

---

## 6. NEAR Blockchain (Оставляем)

### 6.1 Компоненты (НЕ трогаем)

| Компонент | Файл | Назначение |
|-----------|------|-----------|
| RPC клиент | `lib/network/near_custom_client.dart` | Взаимодействие с блокчейном NEAR |
| Near Social API | `lib/modules/home/apis/near_social.dart` | Получение постов, лайков, комментариев |
| Константы | `lib/config/constants.dart:21-25` | RPC endpoints |
| Retry interceptor | `lib/network/dio_interceptors/retry_with_change_base_url.dart` | Обработка ошибок RPC |

### 6.2 Конфигурация

**Файл:** `lib/config/constants.dart` (строки 21-25)

```dart
class NearUrls {
  static const blockchainRpc = "https://free.rpc.fastnear.com/";
  static const nearSocialApi = "https://api.near.social";
  static const nearSocialIpfsMediaHosting = "https://ipfs.near.social/ipfs/";
}
```

### 6.3 Зависимости NEAR

```yaml
flutterchain: ^3.0.3          # Blockchain взаимодействие
dio: ^5.9.0                   # HTTP клиент для API
dio_smart_retry: ^6.0.0       # Retry логика
```

---

## 7. План удаления

### 7.1 Файлы для модификации

| Файл | Действие | Сложность |
|------|----------|-----------|
| `pubspec.yaml`  | Удалить зависимости Supabase, Firebase, notifications, websocket | Низкая |
| `lib/main.dart` | Удалить инициализацию Supabase | Низкая |
| `lib/config/constants.dart` | Удалить `SystemsManagmentConstans` | Низкая |
| `lib/modules/vms/core/auth_controller.dart` | Переписать авторизацию без Supabase | Высокая |
| `lib/modules/home/pages/chat/chat_page.dart` | Отключить/заменить чат функционал | Высокая |
| `lib/modules/home/pages/chat/widgets/chat_list_body.dart` | Отключить стриминг чатов | Средняя |
| `lib/modules/home/pages/chat/call_room_page.dart` | Удалить WebSocket код | Низкая |
| `lib/modules/home/vms/chats/user_chats_page_controller.dart` | Отключить edge functions | Средняя |
| `lib/modules/home/vms/chats/chat_page_controller.dart` | Отключить edge functions | Средняя |
| `lib/modules/home/pages/settings/settings_page.dart` | Убрать Supabase logout | Низкая |

### 7.2 Файлы/директории для удаления

| Путь | Тип | Описание |
|------|-----|----------|
| `supabase/` | Директория | Все edge functions и конфигурация |
| `firebase.json` | Файл | Конфигурация Firebase |

### 7.3 Зависимости для удаления из pubspec.yaml

```yaml
# Удалить полностью:
supabase_flutter: ^2.12.0
flutter_local_notifications: ^20.0.0
web_socket_channel: ^3.0.3

# Удалить закомментированные:
# cloud_firestore: ^5.5.1
# cloud_functions: ^4.7.6
# firebase_auth: ^5.3.4
# firebase_core: ^3.8.1
# firebase_messaging: ^15.1.6
# flutter_firebase_chat_core: ^1.6.7
```

---

## 8. Критические последствия

### 8.1 Полная потеря функционала

После удаления Supabase приложение **полностью потеряет**:

| Функционал | Описание |
|------------|----------|
| Система чатов | Невозможно отправлять/получать сообщения |
| Real-time обновления | Нет живых обновлений списка чатов и сообщений |
| Верификация аккаунтов | Нельзя подтвердить владение NEAR аккаунтом |
| Сессии пользователей | Нет персистентной авторизации |
| E2E шифрование | Негде хранить публичные ключи пользователей |

### 8.2 UI элементы, которые перестанут работать

- Экран списка чатов
- Экран чата (отправка/получение сообщений)
- Экран звонков (уже не работает)
- Кнопка logout в настройках

---

## 9. Рекомендации по децентрализации

### 9.1 Альтернативы для Supabase

| Функция Supabase | Децентрализованная альтернатива | Сложность |
|------------------|--------------------------------|-----------|
| База данных | NEAR Social DB (SocialDB contract) | Высокая |
| Real-time подписки | WebSocket к публичному NEAR indexer | Средняя |
| Верификация подписи | Клиентская верификация через near-api-js | Средняя |
| Хранение ключей | Social DB или локальное хранилище | Средняя |
| Edge Functions | Логика переносится на клиент или смарт-контракты | Высокая |

### 9.2 Архитектура после децентрализации

```
┌─────────────────────────────────┐
│   Flutter Mobile App            │
│  (Полностью клиентская логика)  │
└──────────────┬──────────────────┘
               │
        ┌──────┴──────────┐
        │                 │
   ┌────▼─────┐    ┌─────▼──────┐
   │ NEAR RPC │    │ NEAR Social│
   │ Blockchain│    │ API/Indexer│
   │           │    │            │
   │ Транзакции│    │ Чтение     │
   │ Подписи   │    │ данных     │
   └───────────┘    └────────────┘
```

### 9.3 Этапы миграции

1. **Этап 1: Очистка** (Текущий)
   - Удалить Firebase (уже отключён)
   - Удалить push notifications (не используется)
   - Удалить WebSocket (не работает)

2. **Этап 2: Временное отключение чатов**
   - Скрыть UI чатов
   - Удалить Supabase зависимость
   - Сохранить код для будущей миграции

3. **Этап 3: Децентрализация чатов**
   - Реализовать хранение сообщений в NEAR Social DB
   - Реализовать клиентскую верификацию подписей
   - Реализовать E2E шифрование с ключами в Social DB

4. **Этап 4: Real-time функционал**
   - Подключить WebSocket к публичному NEAR indexer
   - Реализовать polling как fallback

---

## 10. Оценка трудозатрат

| Этап | Описание | Оценка |
|------|----------|--------|
| Очистка неиспользуемого кода | Firebase, notifications, websocket | Простой |
| Удаление Supabase | Удаление зависимости и кода | Средний |
| Временное отключение чатов | Скрытие UI, заглушки | Простой |
| Децентрализация чатов | Полная переработка архитектуры | Сложный |
| Real-time обновления | Интеграция с indexer | Средний |

---

## 11. Контрольный список

### Перед началом работы

- [ ] Создать backup ветку
- [ ] Задокументировать текущую логику чатов
- [ ] Определить приоритет децентрализации

### Этап очистки

- [ ] Удалить закомментированные Firebase зависимости
- [ ] Удалить `flutter_local_notifications`
- [ ] Удалить `web_socket_channel`
- [ ] Удалить `firebase.json`
- [ ] Удалить закомментированный Firebase код в `auth_controller.dart`
- [ ] Удалить `call_room_page.dart`

### Этап удаления Supabase

- [ ] Удалить `supabase_flutter` из pubspec.yaml
- [ ] Удалить инициализацию в `main.dart`
- [ ] Удалить `SystemsManagmentConstans`
- [ ] Обновить `auth_controller.dart`
- [ ] Скрыть/отключить UI чатов
- [ ] Удалить директорию `supabase/`
- [ ] Обновить logout в settings

### Тестирование

- [ ] Проверить запуск приложения
- [ ] Проверить авторизацию через NEAR
- [ ] Проверить работу ленты постов
- [ ] Проверить профиль пользователя
- [ ] Проверить follow/unfollow
- [ ] Проверить poke функционал

---

*Отчёт подготовлен автоматически на основе анализа кодовой базы*
