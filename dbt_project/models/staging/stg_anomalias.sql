-- Gabarito de anomalias injetadas artificialmente no projeto 1, usado para
-- validar a deteccao de anomalias e para cruzamento com as metricas de performance.
-- Fonte: gabarito_anomalias (raw)
select
    id_campanha,
    id_disparo,
    cast(flg_anomalia_injetada as bool) as flg_anomalia_injetada,
    tipo_anomalia_injetada
from {{ source('email_campaign_raw', 'gabarito_anomalias') }}
