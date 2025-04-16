yc compute instance delete web
yc compute instance delete log
yc vpc subnet update \
  --name default-ru-central1-b \
  --route-table-name ""
yc vpc route-table delete nat-route
yc vpc gateway delete nat-gateway
