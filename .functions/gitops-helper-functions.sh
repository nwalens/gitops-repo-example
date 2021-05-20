function argocd_application_setup {
    local appGroup=$1
    local appName=$2
    local environment=$3
    local teamName=$4
    echo -n "Setting up ArgoCD application..."
    if [[ ! -d ${appGroup}/environments/$environment/${appName}/argocd ]]; then
        mkdir -p ${appGroup}/environments/$environment/${appName}/argocd
    fi

    patch='[{"op": "replace", "path": "/spec/destination/namespace", "value": "'${ns_prefix}-${appGroup}'"},
            {"op": "replace", "path": "/spec/project", "value": "'${appGroup}-project'"},
            {"op": "replace", "path": "/spec/source/path", "value": "'${appGroup}/environments/$environment/${appName}'"}]'

    kustomize_set_directory "${appGroup}/environments/$environment/${appName}/argocd"
    kustomize_add_resource "../../../../../templates/argocd/application"
    kustomize_set_namespace "argocd"
    kustomize_set_nameprefix "${appName}-${ns_prefix}-"
    kustomize_add_labels "app.kubernetes.io/name:${appName} app.kubernetes.io/namespace:${ns_prefix}-${appGroup} app.company.io/team:${teamName} app.company.io/environment:${environment}"
    kustomize_add_patch "--group argoproj.io --version v1alpha1 --kind Application --name application"

    echo "done"
}

function subscribe_to_cluster {
    local appGroup=$1
    local appName=$2
    local environment=$3
    local clusterID=$4

    [[ ! -d target/${clusterID} ]] && mkdir -p target/${clusterID}
    echo -n "Subscribing application to cluster ${clusterID}..."

    kustomize_set_directory "target/${clusterID}" "../../${appGroup}"
    kustomize_add_resource "../../${appGroup}"
    kustomize_add_resource "../../${appGroup}/environments/$environment/${appName}/argocd"

    echo "done"
}

function update_image {
    local appGroup=$1
    local appName=$2
    local environment=$3
    local imagePatch=$4

    echo -n "Updating image..."
    if [[ -f ${appGroup}/environments/$environment/${appName}/kustomization.yaml ]]; then
       kustomize_set_directory "${appGroup}/environments/$environment/${appName}"
       kustomize_set_image "${imagePatch}"
       echo "done"
    else
        echo "Error: Service not found or not configured yet"
        exit 1
    fi
}