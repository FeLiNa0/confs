#!/bin/sh
for OTHERSCRIPT in ./correct-kubernetes-cluster.sh ./infra/correct-kubernetes-cluster.sh ./automation/correct-kubernetes-cluster.sh; do
    if [ -x $OTHERSCRIPT ]; then
        echo $OTHERSCRIPT
        $OTHERSCRIPT
    fi
done

echo "WARNING: DESTRUCTIVE KUBERNETES OPERATION"
echo "Current kubernetes cluster: $(kubectl config current-context)"
echo "Are you sure? Type yes"

sleep 0.5
read INPUT
if [ "$INPUT" = "yes" ]; then
    echo "Running"
    exit 0
fi
echo "Cancelled operation"
exit 1
