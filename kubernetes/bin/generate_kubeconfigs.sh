#!/bin/bash

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Initialize variables
filter=""
force=0

# Function to show usage
usage() {
    echo -e "${YELLOW}Usage: $0 [-f|--force] [filter]"
    echo -e "  -f, --force    Rename existing kubeconfig files with a .old.TIMESTAMP extension"
    echo -e "  filter         Optional substring to filter cluster names${NC}"
    exit 1
}

# Parse command-line options
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -f|--force) force=1 ;;
        -h|--help) usage ;;
        *) egrep_filter="$1" ;;
    esac
    shift
done

# Check that dependencies are executable
if ! command -v omnictl 2>&1 >/dev/null ; then
    echo -e "${RED}ERROR: Please install omnictl${NC}"
    echo "Make sure to install the omniconfig file as well."
    echo "Follow this guide: https://omni.siderolabs.com/docs/how-to-guides/how-to-install-and-configure-omnictl/"
    echo "Try downloading it from a URL like https://powerflex.omni.siderolabs.io/omni/"
    exit 2
fi

if ! command -v yq 2>&1 >/dev/null ; then
    echo -e "${RED}ERROR: Please install mikefarah's yq${NC}"
    echo "Run 'brew install yq' or see https://github.com/mikefarah/yq/"
    echo "Not to be confused with kislyuk's python-yq"
    exit 2
else
    if ! yq -V | grep mikefarah > /dev/null ; then
        echo -e "${RED}ERROR: Please install mikefarah's yq${NC}"
        echo "The yq binary in your PATH does not appear to be a recent version of mikefarah's yq"
        echo "Run 'brew install yq' or see https://github.com/mikefarah/yq/"
        exit 2
    fi
fi

# Check that a non-default omniconfig is installed
if omnictl config info | grep "grpc://127.0.0.1:8080" ; then
    echo -e "${RED}WARNING: The current omni context is likely the default context.${NC}"
    echo "Make sure you're using a desired omni context with 'omnictl config info'"
fi

echo '+ omnictl config info'
omnictl config info

# Fetch all cluster names and store the output in YAML format
cluster_output=$(omnictl get clusters -o yaml)
if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to get clusters${NC}"
    exit 1
fi

# Parse the cluster IDs using yq, exclude lines that only contain '---'
cluster_ids=$(echo "$cluster_output" | yq e '.metadata.id' - | grep -v '^---$')

# Check if yq found any cluster IDs
if [ -z "$cluster_ids" ]; then
    echo -e "${RED}No clusters found or failed to parse cluster IDs${NC}"
    exit 1
fi

# Loop through the cluster IDs
for cluster_id in $cluster_ids; do
    # If a filter is set, skip clusters that don't contain the filter substring
    if [ -n "$filter" ] && [[ $cluster_id != *"$filter"* ]]; then
        continue
    fi
    
    if [ -n "$egrep_filter" ] && ! echo "$cluster_id" | grep -E "$egrep_filter" ; then
        continue
    fi

    kubeconfig_file="${cluster_id}.yaml"
    # Check if kubeconfig file already exists and rename if force is set
    if [ -f "$kubeconfig_file" ]; then
        if [ "$force" -eq 1 ]; then
            timestamp=$(date +%s)
            mv "$kubeconfig_file" "${kubeconfig_file}.old.${timestamp}"
            echo -e "${YELLOW}Renamed existing kubeconfig file: ${kubeconfig_file} -> ${kubeconfig_file}.old.${timestamp}${NC}"
        else
            echo -e "${YELLOW}Kubeconfig file for cluster $cluster_id already exists: $kubeconfig_file (use -f to rename)${NC}"
            continue
        fi
    fi

    # Generate kubeconfig
    echo -e "Generating kubeconfig for cluster: ${GREEN}$cluster_id${NC}"
    omnictl kubeconfig "$kubeconfig_file" -c "$cluster_id"
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to generate kubeconfig for cluster: $cluster_id${NC}"
    else
        echo -e "${GREEN}Kubeconfig generated successfully for cluster: $cluster_id${NC}"
    fi
done

echo -e "${GREEN}Kubeconfig files generation completed.${NC}"
