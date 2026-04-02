-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Хост: MySQL-8.4:3306
-- Время создания: Мар 23 2026 г., 10:31
-- Версия сервера: 8.4.7
-- Версия PHP: 8.3.29

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- База данных: `classroom_db`
--

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `active_sessions`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `active_sessions` (
`computer_name` varchar(100)
,`computer_problem` text
,`created_at` timestamp
,`current_duration` bigint
,`duration_minutes` int
,`group_name` varchar(50)
,`id` int
,`ip_address` varchar(45)
,`last_heartbeat` datetime
,`login_time` datetime
,`logout_time` datetime
,`real_status` varchar(14)
,`session_id` varchar(100)
,`status` enum('АКТИВЕН','ЗАВЕРШЁН','АВАРИЙНЫЙ')
,`surname` varchar(100)
,`updated_at` timestamp
);

-- --------------------------------------------------------

--
-- Структура таблицы `activity_log`
--

CREATE TABLE `activity_log` (
  `id` int NOT NULL,
  `activity_id` varchar(50) NOT NULL COMMENT 'GUID, генерируется клиентом',
  `session_id` varchar(100) NOT NULL,
  `computer_name` varchar(100) NOT NULL,
  `tracked_app_id` int DEFAULT NULL COMMENT 'FK на tracked_apps',
  `app_name` varchar(255) NOT NULL,
  `process_name` varchar(255) DEFAULT NULL,
  `category` varchar(50) NOT NULL,
  `window_title` varchar(500) DEFAULT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime DEFAULT NULL,
  `duration_seconds` int DEFAULT '0',
  `is_active` tinyint(1) DEFAULT '1',
  `last_seen` datetime DEFAULT NULL COMMENT 'Обновляется периодически пока активно',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-------------------------------------------

--
-- Структура таблицы `remote_commands`
--

CREATE TABLE `remote_commands` (
  `id` int NOT NULL,
  `computer_name` varchar(100) NOT NULL COMMENT 'Имя ПК (например PC01-cab31)',
  `session_id` varchar(100) DEFAULT NULL COMMENT 'ID сессии (опционально)',
  `command_type` enum('KILL_PROCESS','KILL_BY_TITLE','MESSAGE','LOCK_SCREEN') NOT NULL DEFAULT 'KILL_PROCESS',
  `target` varchar(255) NOT NULL COMMENT 'Имя процесса (chrome.exe) или паттерн заголовка',
  `status` enum('PENDING','EXECUTED','FAILED','EXPIRED') NOT NULL DEFAULT 'PENDING',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `executed_at` datetime DEFAULT NULL,
  `result` varchar(500) DEFAULT NULL COMMENT 'Результат выполнения',
  `created_by` varchar(100) DEFAULT NULL COMMENT 'Кто создал команду'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Очередь команд для удалённого управления ПК';

-- --------------------------------------------------------

--
-- Структура таблицы `sessions`
--

CREATE TABLE `sessions` (
  `id` int NOT NULL,
  `session_id` varchar(100) NOT NULL,
  `computer_name` varchar(100) NOT NULL,
  `group_name` varchar(50) NOT NULL,
  `surname` varchar(100) NOT NULL,
  `login_time` datetime NOT NULL,
  `logout_time` datetime DEFAULT NULL,
  `duration_minutes` int DEFAULT '0',
  `status` enum('АКТИВЕН','ЗАВЕРШЁН','АВАРИЙНЫЙ') DEFAULT 'АКТИВЕН',
  `computer_problem` text,
  `last_heartbeat` datetime DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-
-- --------------------------------------------------------

--
-- Структура таблицы `students`
--

CREATE TABLE `students` (
  `id` int NOT NULL,
  `group_name` varchar(20) NOT NULL,
  `surname` varchar(100) NOT NULL,
  `first_name` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
--------------------------------------------------

--
-- Структура таблицы `sync_queue`
--

CREATE TABLE `sync_queue` (
  `id` int NOT NULL,
  `session_id` varchar(100) NOT NULL,
  `action_type` enum('INSERT','UPDATE','CLOSE') NOT NULL,
  `data_json` text NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `processed` tinyint(1) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `tracked_apps`
--

CREATE TABLE `tracked_apps` (
  `id` int NOT NULL,
  `process_name` varchar(255) DEFAULT NULL COMMENT 'Имя процесса (напр. minecraft.exe)',
  `display_name` varchar(255) NOT NULL COMMENT 'Отображаемое имя',
  `category` enum('GAME','LAUNCHER','BROWSER_GAME','SOCIAL_MEDIA','OTHER') DEFAULT 'GAME',
  `detection_type` enum('PROCESS','WINDOW_TITLE','BOTH') DEFAULT 'PROCESS' COMMENT 'PROCESS = по имени процесса, WINDOW_TITLE = по заголовку окна, BOTH = процесс + заголовок',
  `title_pattern` varchar(500) DEFAULT NULL COMMENT 'Подстрока для поиска в заголовке окна',
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-
--
-- Структура таблицы `users`
--

CREATE TABLE `users` (
  `id` int NOT NULL,
  `login` varchar(50) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `display_name` varchar(100) NOT NULL,
  `role` enum('admin','teacher') NOT NULL DEFAULT 'teacher',
  `cabinet_ids` varchar(500) DEFAULT '' COMMENT 'Через запятую: 31,32,46',
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Индексы сохранённых таблиц
--

--
-- Индексы таблицы `activity_log`
--
ALTER TABLE `activity_log`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `activity_id` (`activity_id`),
  ADD KEY `idx_activity_id` (`activity_id`),
  ADD KEY `idx_session` (`session_id`),
  ADD KEY `idx_computer` (`computer_name`),
  ADD KEY `idx_is_active` (`is_active`),
  ADD KEY `idx_start_time` (`start_time`),
  ADD KEY `idx_category` (`category`),
  ADD KEY `idx_tracked_app` (`tracked_app_id`);

--
-- Индексы таблицы `remote_commands`
--
ALTER TABLE `remote_commands`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_computer_pending` (`computer_name`,`status`),
  ADD KEY `idx_created` (`created_at`);

--
-- Индексы таблицы `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `session_id` (`session_id`),
  ADD KEY `idx_session_id` (`session_id`),
  ADD KEY `idx_computer` (`computer_name`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_login_time` (`login_time`),
  ADD KEY `idx_group` (`group_name`),
  ADD KEY `idx_sessions_status` (`status`),
  ADD KEY `idx_sessions_login_date` (`login_time`),
  ADD KEY `idx_sessions_group` (`group_name`),
  ADD KEY `idx_sessions_computer` (`computer_name`),
  ADD KEY `idx_sessions_student` (`surname`,`group_name`);

--
-- Индексы таблицы `students`
--
ALTER TABLE `students`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_group` (`group_name`),
  ADD KEY `idx_surname` (`surname`);

--
-- Индексы таблицы `sync_queue`
--
ALTER TABLE `sync_queue`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_processed` (`processed`);

--
-- Индексы таблицы `tracked_apps`
--
ALTER TABLE `tracked_apps`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_active` (`is_active`),
  ADD KEY `idx_category` (`category`),
  ADD KEY `idx_detection` (`detection_type`);

--
-- Индексы таблицы `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `login` (`login`),
  ADD KEY `idx_role` (`role`),
  ADD KEY `idx_active` (`is_active`);

--
-- AUTO_INCREMENT для сохранённых таблиц
--

--
-- AUTO_INCREMENT для таблицы `activity_log`
--
ALTER TABLE `activity_log`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=883;

--
-- AUTO_INCREMENT для таблицы `remote_commands`
--
ALTER TABLE `remote_commands`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=50;

--
-- AUTO_INCREMENT для таблицы `sessions`
--
ALTER TABLE `sessions`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1363;

--
-- AUTO_INCREMENT для таблицы `students`
--
ALTER TABLE `students`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1038;

--
-- AUTO_INCREMENT для таблицы `sync_queue`
--
ALTER TABLE `sync_queue`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `tracked_apps`
--
ALTER TABLE `tracked_apps`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=403;

--
-- AUTO_INCREMENT для таблицы `users`
--
ALTER TABLE `users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

-- --------------------------------------------------------

--
-- Структура для представления `active_sessions`
--
DROP TABLE IF EXISTS `active_sessions`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `active_sessions`  AS SELECT `s`.`id` AS `id`, `s`.`session_id` AS `session_id`, `s`.`computer_name` AS `computer_name`, `s`.`group_name` AS `group_name`, `s`.`surname` AS `surname`, `s`.`login_time` AS `login_time`, `s`.`logout_time` AS `logout_time`, `s`.`duration_minutes` AS `duration_minutes`, `s`.`status` AS `status`, `s`.`computer_problem` AS `computer_problem`, `s`.`last_heartbeat` AS `last_heartbeat`, `s`.`ip_address` AS `ip_address`, `s`.`created_at` AS `created_at`, `s`.`updated_at` AS `updated_at`, timestampdiff(MINUTE,`s`.`login_time`,now()) AS `current_duration`, (case when ((`s`.`last_heartbeat` is not null) and (`s`.`last_heartbeat` < (now() - interval 120 second))) then 'ПОТЕРЯНА СВЯЗЬ' else `s`.`status` end) AS `real_status` FROM `sessions` AS `s` WHERE (`s`.`status` in ('АКТИВЕН','АВАРИЙНЫЙ')) ;

--
-- Ограничения внешнего ключа сохраненных таблиц
--

--
-- Ограничения внешнего ключа таблицы `activity_log`
--
ALTER TABLE `activity_log`
  ADD CONSTRAINT `activity_log_ibfk_1` FOREIGN KEY (`session_id`) REFERENCES `sessions` (`session_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `activity_log_ibfk_2` FOREIGN KEY (`tracked_app_id`) REFERENCES `tracked_apps` (`id`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
