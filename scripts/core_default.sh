# Recreates the bibdata core empty
# (use this if you installed Solr locally)
solr delete -c bibdata
solr create -c bibdata

# Recreates the bibdata core empty
# (use this if you installed Solr via a Docker container)
docker exec -it solr-container solr delete -c bibdata
docker exec -it solr-container solr create_core -c bibdata
docker exec -it solr-container post -c bibdata books.json


# Other docker commands
# docker stop solr-container
# docker rm solr-container
#
# docker system prune -a -f
