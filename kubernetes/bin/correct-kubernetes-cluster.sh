#!/bin/sh
for OTHERSCRIPT in ./correct-kubernetes-cluster.sh ./infra/correct-kubernetes-cluster.sh ./automation/correct-kubernetes-cluster.sh; do
    if [ -x $OTHERSCRIPT ]; then
        echo $OTHERSCRIPT
        $OTHERSCRIPT
    fi
done

echo "$(tput bold)$(tput setaf 1)WARNING: DESTRUCTIVE KUBERNETES OPERATION$(tput sgr0). Is this the corrrect kubernetes cluster?"
echo "$(tput bold)$(kubectl config current-context)$(tput sgr0)"

sleep 0.7
read -p "If so, type yes: " -n 3 INPUT

if [ "$INPUT" = "yes" ]; then
    echo "Running"
    exit 0
fi
echo "Cancelled operation"
exit 1
