# Parse script arguments
for i in "$@"
do
case "$i" in
	--pods=*)
	PODS="${i#*=}"
    shift # past argument=value
    ;;
  --service-ip=*)
	SERVICE_IP="${i#*=}"
    shift # past argument=value
    ;;
	*)
	die "unknown option '$i'"
	;;
esac
done

# Exit as soon as any line fails
set -e

OPERATION_TYPE=('read')
MAX_OPS=(10000)

kubectl run cockroachdb -it --image=cockroachdb/cockroach:latest --rm \
  --restart=Never -- workload init kv --db kv --drop --sequential \
  postgresql://root@$SERVICE_IP:26257?sslmode=disable

# Seed the database
kubectl run cockroachdb -it --image=cockroachdb/cockroach:v22.2.7 --rm \
  --restart=Never -- workload run kv --max-ops 1000 --sequential \
  --concurrency 10 --db kv --read-percent 0 \
  postgresql://root@$SERVICE_IP:26257?sslmode=disable

for OPERATION in "${OPERATION_TYPE[@]}"
do
  for OP_COUNT in "${MAX_OPS[@]}"
  do
    x=0
    while [ $x -lt 10 ]
    do
      if [ $OPERATION == 'read' ]
      then
        READ_PERCENT=100
      else
        READ_PERCENT=0
      fi

      kubectl run cockroachdb -it --image=cockroachdb/cockroach:v22.2.7 --rm \
      --restart=Never -- workload run kv --max-ops "$OP_COUNT" \
      --concurrency 10 --db kv --read-percent $READ_PERCENT \
      --display-format=incremental-json --sequential \
      postgresql://root@$SERVICE_IP:26257?sslmode=disable >> "cmd-out/$PODS-pods-$OP_COUNT-$OPERATION"

      x=$(( $x + 1 ))
    done
  done
done
