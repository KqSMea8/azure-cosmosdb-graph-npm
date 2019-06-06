
# PowerShell script to load the materialized views into CosmosDB/Graph with the SQL API.
# Chris Joakim, Microsoft, 2019/06/06

db=dev
coll=views
sleep_time=50

echo ''
echo '=== load_materialized_views ...'
node load_materialized_views.js $db $coll $sleep_time > tmp/load_materialized_views.txt

echo 'done'
