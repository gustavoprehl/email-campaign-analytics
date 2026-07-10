-- Eventos individuais de campanha (sent/open/click/bounce/unsubscribe)
-- Fonte: fato_evento (raw)
select
    id_evento,
    id_campanha,
    id_subscriber,
    tipo_evento,
    id_disparo,
    timestamp(dat_evento) as dat_evento
from {{ source('email_campaign_raw', 'fato_evento') }}
