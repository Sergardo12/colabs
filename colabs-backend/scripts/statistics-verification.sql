-- Verificación manual de estadísticas (no se ejecuta automáticamente).
-- Uso:
--   psql -U <user> -d <db> -v user_id='<uuid del usuario>' -v profile_id='<uuid del profile_colab>' -f scripts/statistics-verification.sql
--
-- Solo contiene SELECT. No crea ni modifica datos.

\echo '== Zona horaria y tipos de fecha =='
SHOW timezone;
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name IN ('service_requests', 'users', 'monthly_goal')
  AND column_name IN ('completion_date', 'creation_date', 'registration_date', 'created_at', 'updated_at')
ORDER BY table_name, column_name;

\echo '== Perfil del colaborador =='
SELECT u.id AS user_id, p.id AS profile_colab_id, u.registration_date
FROM users u
JOIN profile_colab p ON p.user_id = u.id
WHERE u.id = :'user_id';

\echo '== Servicios ofrecidos: semana UTC (barras) =='
WITH week_bounds AS (
  SELECT date_trunc('week', now() AT TIME ZONE 'UTC') AS week_start
)
SELECT EXTRACT(ISODOW FROM sr.completion_date)::int AS weekday,
       count(DISTINCT sr.id) AS value
FROM service_requests sr
LEFT JOIN proposals ap
  ON ap.service_request_id = sr.id
 AND ap.status = 'accepted'
CROSS JOIN week_bounds w
WHERE sr.status = 'completed'
  AND sr.completion_date IS NOT NULL
  AND sr.completion_date >= w.week_start
  AND sr.completion_date < w.week_start + interval '7 days'
  AND (
    sr.profile_colab_id = :'profile_id'
    OR (sr.profile_colab_id IS NULL AND ap.profile_colab_id = :'profile_id')
  )
GROUP BY 1
ORDER BY 1;

\echo '== Total: hoy / mes actual / año actual (rangos semiabiertos) =='
WITH bounds AS (
  SELECT date_trunc('day', now() AT TIME ZONE 'UTC') AS day_start,
         date_trunc('month', now() AT TIME ZONE 'UTC') AS month_start,
         date_trunc('year', now() AT TIME ZONE 'UTC') AS year_start
)
SELECT
  count(DISTINCT sr.id) FILTER (
    WHERE sr.completion_date >= b.day_start
      AND sr.completion_date < b.day_start + interval '1 day'
  ) AS total_days,
  count(DISTINCT sr.id) FILTER (
    WHERE sr.completion_date >= b.month_start
      AND sr.completion_date < b.month_start + interval '1 month'
  ) AS total_months,
  count(DISTINCT sr.id) FILTER (
    WHERE sr.completion_date >= b.year_start
      AND sr.completion_date < b.year_start + interval '1 year'
  ) AS total_years
FROM service_requests sr
LEFT JOIN proposals ap
  ON ap.service_request_id = sr.id
 AND ap.status = 'accepted'
CROSS JOIN bounds b
WHERE sr.status = 'completed'
  AND sr.completion_date IS NOT NULL
  AND (sr.profile_colab_id = :'profile_id'
    OR (sr.profile_colab_id IS NULL AND ap.profile_colab_id = :'profile_id'));

\echo '== Tasa histórica: solicitados vs ofrecidos =='
SELECT
  (SELECT count(DISTINCT id) FROM service_requests
    WHERE user_id = :'user_id' AND status <> 'cancelled') AS requested,
  (SELECT count(DISTINCT sr.id)
    FROM service_requests sr
    LEFT JOIN proposals ap
      ON ap.service_request_id = sr.id
     AND ap.status = 'accepted'
     WHERE sr.status = 'completed'
       AND sr.completion_date IS NOT NULL
       AND (sr.profile_colab_id = :'profile_id'
         OR (sr.profile_colab_id IS NULL AND ap.profile_colab_id = :'profile_id'))
   ) AS offered;


\echo '== Promedio de calificaciones (comentarios activos) =='
SELECT round(avg(cr.rating)::numeric, 1) AS average_rating
FROM comment_requests cr
JOIN service_requests sr ON sr.id = cr.service_request_id
LEFT JOIN proposals ap ON ap.service_request_id = sr.id AND ap.status = 'accepted'
WHERE cr.status = 'active'
  AND sr.status = 'completed'
  AND sr.completion_date IS NOT NULL
  AND (sr.profile_colab_id = :'profile_id'
    OR (sr.profile_colab_id IS NULL AND ap.profile_colab_id = :'profile_id'));

\echo '== Flujo B: servicios de chat sin proposal ni profile_colab_id (deben quedar excluidos) =='
SELECT sr.id, sr.status, sr.completion_date, c.id AS conversation_id
FROM service_requests sr
JOIN conversations c ON c.service_request_id = sr.id
WHERE c.post_id IS NOT NULL
  AND sr.profile_colab_id IS NULL
  AND NOT EXISTS (
    SELECT 1 FROM proposals p WHERE p.service_request_id = sr.id
  );

\echo '== Meta del mes actual =='
SELECT amount, offered, month, year
FROM (
  SELECT mg.amount,
         (
           SELECT count(DISTINCT sr.id)
           FROM service_requests sr
           LEFT JOIN proposals ap
             ON ap.service_request_id = sr.id
            AND ap.status = 'accepted'
           WHERE sr.status = 'completed'
             AND sr.completion_date >= date_trunc('month', now() AT TIME ZONE 'UTC')
             AND sr.completion_date < date_trunc('month', now() AT TIME ZONE 'UTC') + interval '1 month'
             AND (sr.profile_colab_id = :'profile_id'
               OR (sr.profile_colab_id IS NULL AND ap.profile_colab_id = :'profile_id'))
         ) AS offered,
         mg.month,
         mg.year
  FROM monthly_goal mg
  WHERE mg.profile_colab_id = :'profile_id'
    AND mg.month = EXTRACT(MONTH FROM now() AT TIME ZONE 'UTC')::int
    AND mg.year = EXTRACT(YEAR FROM now() AT TIME ZONE 'UTC')::int
) goal;
