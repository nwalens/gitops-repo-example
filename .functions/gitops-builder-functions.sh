function prepare_base {
    local appGroup=$1
    local gitopsTemplate=$2
    
    if [[ ! -d ${appGroup} ]]; then
        mkdir -p ${appGroup}
    fi
    
    # create argocd project kustomization
    kustomize_set_directory "${appGroup}"
    kustomize_add_resource "../templates/argocd/project"
    kustomize_set_namespace "argocd"
    kustomize_set_nameprefix "${appGroup}-"

    if [[ ! -d ${appGroup}/services ]]; then
        echo -n "Create Service Group and ArgoCD Project..."
        if [[ ! -d templates/${gitopsTemplate}/base ]]; then
            echo -e "Invalid GitOps Template"
            exit 1
        fi
        mkdir -p ${appGroup}/services/base
        kustomize_set_directory "${appGroup}/services/base"
        kustomize_create_kustomization
        echo "done"

        # Load template logic
        if [[ -f templates/${gitopsTemplate}/.gitops-setup/base.sh ]]; then
            . templates/${gitopsTemplate}/.gitops-setup/base.sh
        fi

        for c in $kustomize_components; do
            if [[ -f templates/components/$c/.gitops-setup/base.sh ]]; then
                . templates/components/$c/.gitops-setup/base.sh
            fi
        done
    else
        echo "Service Group ${appGroup} already in place"
    fi
}

function prepare_service {
    local appGroup=$1
    local appName=$2
    local componentType=$3
    local gitopsTemplate=$4

    [[ ! ${setup_base} == "true" ]] && prepare_base ${appGroup} ${gitopsTemplate}
    if [[ ! -d ${appGroup}/services/${appName} ]]; then       
        mkdir -p ${appGroup}/services/${appName}

        # add service specific kustomizations
        echo -n "Setup service..."
        kustomize_set_directory "${appGroup}/services/${appName}"
        kustomize_add_resource "../base"
        kustomize_add_resource "../../../templates/${gitopsTemplate}/base"
        echo "done"

        # Load template logic
        if [[ -f templates/${gitopsTemplate}/.gitops-setup/service.sh ]]; then
            . templates/${gitopsTemplate}/.gitops-setup/service.sh
        fi

        for c in $kustomize_components; do
            if [[ -f templates/components/$c/.gitops-setup/service.sh ]]; then
                . templates/components/$c/.gitops-setup/service.sh
            fi
        done
    else
        echo "Service ${appName} already exists"
    fi
}

function prepare_environment {
    local appGroup=$1
    local appName=$2
    local environment=$3
    local teamName=$4
    local componentType=$5
    local gitopsTemplate=$6
    local clusterID=$7

    [[ ! ${setup_service} == "true" ]] && prepare_service ${appGroup} ${appName} ${componentType} ${gitopsTemplate}
    if [[ ! -d ${appGroup}/environments/$environment/${appName} ]]; then
        mkdir -p ${appGroup}/environments/${environment}/${appName}
        kustomize_set_directory "${appGroup}/environments/${environment}/${appName}"

        # add environment specific kustomizations
        echo -n "Add service to environment..."
        kustomize_add_resource "../../../services/${appName}"
        kustomize_set_namespace "${ns_prefix}-${appGroup}"
        kustomize_set_nameprefix "${appName}-"
        kustomize_add_labels "app.kubernetes.io/name:${appName} app.kubernetes.io/part-of:${appGroup} app.company.io/team:${teamName} app.company.io/environment:${environment} app.company.io/service-priority:${priority} ${extraLabels}"
        echo "done"

        # add components to environment
        echo -n "Adding components..."
        for c in $kustomize_components; do
            if [[ $(echo ${c} | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]') != "null" ]]; then
                kustomize_add_components "../../../../templates/components/$c"
            fi
        done
        echo "done"

        # setup argocd application
        argocd_application_setup ${appGroup} ${appName} ${environment} ${teamName}

        # Load template logic
        if [[ -f templates/${gitopsTemplate}/.gitops-setup/environment.sh ]]; then
            . templates/${gitopsTemplate}/.gitops-setup/environment.sh
        fi

        for c in $kustomize_components; do
            if [[ -f templates/components/$c/.gitops-setup/environment.sh ]]; then
                . templates/components/$c/.gitops-setup/environment.sh
            fi
        done
    else
        echo "Service ${appName} already exists in environment ${environment}"
    fi
}