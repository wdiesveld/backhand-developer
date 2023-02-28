# Backhand Developer DBT project

### Build from scratch

- Fetch ATP ranking data using python script ../python/fetchRankingData.py
- `dbt deps`
- `dbt run-operation fix_missing_ranking_dates`
- `dbt build`

### Update data

- First fetch new data, then
- `dbt build`