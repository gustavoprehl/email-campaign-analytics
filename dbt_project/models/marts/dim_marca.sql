select
    id_marca,
    nome_marca
from {{ ref('stg_marcas') }}
