-- Garante que CTR esta entre 0 e 1 (nao pode ser negativo nem maior que 100%)
select id_campanha, dat_referencia, ctr
from {{ ref('fato_agregado_diario') }}
where ctr < 0 or ctr > 1
