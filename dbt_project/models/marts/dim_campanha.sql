select
    id_campanha,
    id_marca,
    nome_jornada,
    tipo_campanha,
    dat_inicio,
    dat_fim
from {{ ref('stg_campanhas') }}
