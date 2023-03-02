# Backhand Developer DBT project

### Build from scratch

- `dbt deps`
- `dbt compile` (needed to compile the load_ranking_raw sql file, which will be invoked by the python script)
- Fetch ATP ranking data using python script ../python/fetchRankingData.py
- `dbt build`

### Update data

- First fetch new data, then
- `dbt build`