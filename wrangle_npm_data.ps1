
# PowerShell script to wrangle the data obtained by the "spider_npm" process.
# Chris Joakim, Microsoft, 2019/06/06

node main.js aggregate_lib_files # > tmp/wrangle_npm_data.txt

# grep the file to grok the format of these people attributes
grep -i "author"       -A 3 data/aggregated_libraries.json > tmp/author.txt
grep -i "contributors" -A 4 data/aggregated_libraries.json > tmp/contributors.txt
grep -i "maintainers"  -A 4 data/aggregated_libraries.json > tmp/maintainers.txt

node main.js create_gremlin_load_file 

wc   data/gremlin/gremlin_load_file.txt
uniq data/gremlin/gremlin_load_file.txt > data/gremlin/gremlin_load_file_uniq.txt
wc   data/gremlin/gremlin_load_file_uniq.txt

echo 'all vertices:'
cat data/gremlin/gremlin_load_file_uniq.txt | grep g.addV | wc -l

echo 'all edges:'
cat data/gremlin/gremlin_load_file_uniq.txt | grep addE | wc -l

echo 'library vertices:'
cat data/gremlin/gremlin_load_file_uniq.txt | grep addV | grep library | grep desc | wc -l

echo 'maintainer vertices:'
cat data/gremlin/gremlin_load_file_uniq.txt | grep addV | grep maintainer | grep email | wc -l

echo 'uses_lib edges:'
cat data/gremlin/gremlin_load_file_uniq.txt | grep addE | grep uses_lib | wc -l

echo 'used_by_lib edges:'
cat data/gremlin/gremlin_load_file_uniq.txt | grep addE | grep used_by_lib | wc -l

echo 'maintains edges:'
cat data/gremlin/gremlin_load_file_uniq.txt | grep addE | grep maintains | wc -l

echo 'knows edges:'
cat data/gremlin/gremlin_load_file_uniq.txt | grep addE | grep knows |  wc -l

echo 'done'
