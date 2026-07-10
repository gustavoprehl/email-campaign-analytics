{% docs __overview__ %}

# Email Campaign Analytics

Este projeto dbt transforma os dados brutos de campanhas de e-mail marketing
(carregados no dataset `email_campaign_raw` a partir dos CSVs gerados pelo
projeto [email-campaign-anomaly-detection](https://github.com/gustavoprehl/email-campaign-anomaly-detection))
em um esquema estrela pronto para consumo em BI.

## Camadas

- **staging**: uma model por tabela fonte, com cast de tipos e nomes padronizados.
- **intermediate**: agregacao de eventos (estrutura longa) em metricas por disparo.
- **marts**: dimensoes e fatos finais, consumidos pelo Power BI e Looker Studio.

{% enddocs %}
