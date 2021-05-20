function check_vars {

    ns_prefix=""
    dotnet_env=""

    appGroup=$(echo ${appGroup} | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]' | sed -E -e 's/_|\//-/g' | sed -E -e 's/^-|-$//g')
    appName=$(echo ${appName} | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]' | sed -E -e 's/_|\//-/g' | sed -E -e 's/^-|-$//g')
    environment=$(echo ${environment} | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]' | sed -E -e 's/_|\//-/g' | sed -E -e 's/^-|-$//g')
    teamName=$(echo ${teamName} | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]' | sed -E -e 's/_|\//-/g' | sed -E -e 's/^-|-$//g')
    componentType=$(echo ${componentType} | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]' | sed -E -e 's/_|\//-/g' | sed -E -e 's/^-|-$//g')
    subscribeToCluster=$(echo ${subscribeToCluster} | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]' | sed -E -e 's/_|\//-/g' | sed -E -e 's/^-|-$//g')
    [[ ! ${subscribeToCluster} =~ "cp" ]] && unset subscribeToCluster

    [[ "x$kustomize_components" == "x" ]] && kustomize_components=""
    [[ "x$gitopsTemplate" == "x" ]] && gitopsTemplate="default-template"
    [[ "x${componentType}" == "x" ]] && componentType="microservice"
    [[ "x${appGroup}" == "x" ]] && echo "Error definning application group" && exit 1
    [[ "x${environment}" == "x" ]] && echo "Environment not defined" && exit 1
    [[ "x${pushToGit}" == "x" ]] && pushToGit=false

    # define namespace prefix
    case ${environment} in
        dev|development)
            ns_prefix="${ns_prefix}dv"
            environment="dev"
        ;;
        qa)
            ns_prefix="${ns_prefix}qa"
        ;;
        uat)
            ns_prefix="${ns_prefix}ut"
            dotnet_env="Staging"
        ;;
        prod)
            ns_prefix="${ns_prefix}pr"
        ;;
        test)
            ns_prefix="${ns_prefix}ts"
        ;;
        stage|staging)
            ns_prefix="${ns_prefix}st"
            environment="staging"
        ;;
        *)
            echo "Invalid environment (${environment})"
            echo "Valid options for environment are: dev or development, qa, uat, prod or production, test and stage"
            exit 1
        ;;
    esac
    case ${teamName} in
        dev|development)
            ns_prefix="${ns_prefix}dv"
            teamName="development"
        ;;
        qa)
            ns_prefix="${ns_prefix}qa"
        ;;
        data|data-engineering)
            ns_prefix="${ns_prefix}dt"
            teamName="data-engineering"
        ;;
        devops)
            ns_prefix="${ns_prefix}do"
        ;;
        it)
            ns_prefix="${ns_prefix}it"
        ;;
        networks)
            ns_prefix="${ns_prefix}nw"
        ;;
        infrastructure)
            ns_prefix="${ns_prefix}inf"
        ;;
        *)
            echo "Invalid Team Name (${teamName})"
            echo "Valid options for teams are : dev or development, qa, data or data-engineering, devops, it, networks and systems"
            exit 1
        ;;
    esac
}

function print_help {
    echo -e "
        \t VALID OPTIONS
        \t |--------------------------------------------------------------------------------------------------------------------------|
        \t |       OPTION      |  Environment Variable  |                                 DESCRIPTION                                 |  
        \t |--------------------------------------------------------------------------------------------------------------------------|
        \t | -a <string>       | (appType)              | Type of application e.g. dotnet, dotnetcore, nodejs                         |
        \t | -b                |                        | Setup the base (default false)                                              |
        \t | -e <string>       | (environment)          | Environment name                                                            |
        \t | -f <file>         |                        | Load a file containing the configuration                                    |
        \t | -g <string>       | (appGroup)             | Application group name or in which group should this application be placed  |
        \t | -i <string>       | (imagePatch)           | kutomize image patch string .e.g. app-image=registry/namespave/image:tag    |
        \t | -N <string>       | (teamName)             | Team name                                                                   |
        \t | -n <string>       | (appName)              | Application/Service name                                                    |
        \t | -p                | (pushToGit)            | Push changes to git (default false)                                         |
        \t | -S <string>       | (subscribeToCluster)   | Subscribe application to given cluster                                      |
        \t | -s                |                        | Setup the service (default false)                                           |
        \t | -T <string>       | (gitopsTemplate)       | Gitops template name to be used for this setup                              |
        \t | -t <string>       | (componentType)        | The type of this component e.g. microservice                                |
        \t | -v                |                        | Setup the environment (default false)                                       |
        \t | -L <string>       | (extraLabels)          | Add extra labels to the manifests e.g. 'apps.company.io/name:value'         |
        \t | -c <string>       | (components)           | Add extra components to the deployment                                      |
        \t \--------------------------------------------------------------------------------------------------------------------------/
    "
}