function kustomize_set_directory {
    kustomization_directory=$1
    kustomize_exec_dir=$PWD
}

function kustomize_check_result {
    local result=$1
    local kustomize_location=$2
    local err_desc=$3
    if [[ ${result} != 0 ]]; then
        echo "${err_desc} in ${kustomize_location}"
        cd ${kustomize_exec_dir}
        exit 1
    fi
}

function kustomize_create_kustomization {
    cd ${kustomization_directory} 1>&2 > /dev/null
    if [[ ! -f kustomization.yaml ]]; then
        kustomize create
        kustomize_check_result $? "${kustomization_directory}/kustomization.yaml" "Error: Could not create kustomization file"
    fi
    cd ${kustomize_exec_dir}
}

function kustomize_add_resource {
    local base=$1
    kustomize_create_kustomization
    if [[ ! "x${base}" == "x" ]]; then
        cd ${kustomization_directory} 1>&2 > /dev/null
        if [[ ! $(grep  "^- ${base}$" kustomization.yaml) ]]; then
            kustomize edit add base ${base}
            kustomize_check_result $? "${kustomization_directory}/kustomization.yaml" "Error: Could not add base"
        fi
        cd ${kustomize_exec_dir}
    fi
}

function kustomize_set_namespace {
    local namespace=$1
    kustomize_create_kustomization
    if [[ ! "x${namespace}" == "x" ]]; then
        cd ${kustomization_directory} 1>&2 > /dev/null
        kustomize edit set namespace ${namespace}
        kustomize_check_result $? "${kustomization_directory}/kustomization.yaml" "Error: could not set namespace"
        cd ${kustomize_exec_dir}
    fi

}

function kustomize_set_nameprefix {
    local nameprefix=$1
    kustomize_create_kustomization
    if [[ ! "x${nameprefix}" == "x" ]]; then
        cd ${kustomization_directory} 1>&2 > /dev/null
        kustomize edit set nameprefix ${nameprefix}
        kustomize_check_result $? "${kustomization_directory}/kustomization.yaml" "Error: could not set nameprefix"
        cd ${kustomize_exec_dir}
    fi
}

function kustomize_add_labels {
    local labels=$1
    kustomize_create_kustomization
    if [[ ! "x${labels}" == "x" ]]; then
        cd ${kustomization_directory} 1>&2 > /dev/null
        kustomize edit add label -f ${labels}
        kustomize_check_result $? "${kustomization_directory}/kustomization.yaml" "Error: could not add labels"
        cd ${kustomize_exec_dir}
    fi
}

function kustomize_add_configmap {
    local configmap_config=$1
    kustomize_create_kustomization
    if [[ ! "x${configmap_config}" == "x" ]]; then
        cd ${kustomization_directory} 1>&2 > /dev/null
        kustomize edit add configmap ${configmap_config}
        kustomize_check_result $? "${kustomization_directory}/kustomization.yaml" "Error: could not add configmap"
        cd ${kustomize_exec_dir}
    fi
}

function kustomize_add_patch {
    # this function requires a global variable names 'patch'
    # ${patch} is a global variable and must be set prior to calling this function
    # Due to the format of json patches, they are not easily read as a parameter in bash functions due to new-lines

    local patch_target=$1
    kustomize_create_kustomization
    if [[ ! "x${patch_target}" == "x" ]]; then
        cd ${kustomization_directory} 1>&2 > /dev/null
        if [[ ! $(grep  "^${patch}$" kustomization.yaml) ]]; then
            kustomize edit add patch ${patch_target} --patch "${patch}"
            kustomize_check_result $? "${kustomization_directory}/kustomization.yaml" "Error: could not add patch"
        fi
        cd ${kustomize_exec_dir}
    fi
}

function kustomize_set_image {
    # this function requires a global variable names 'patch_image'
    # ${patch_image} is a global variable and must be set prior to calling this function
    # Due to the format of json patches, they are not easily read as a parameter in bash functions due to new-lines

    local patch_image=$1
    kustomize_create_kustomization
    if [[ ! "x${patch_image}" == "x" ]]; then
        cd ${kustomization_directory} 1>&2 > /dev/null
        kustomize edit set image ${patch_image}
        kustomize_check_result $? "${kustomization_directory}/kustomization.yaml" "Error: could not patch image"
        cd ${kustomize_exec_dir}
    fi
}

function kustomize_add_components {
    local kustomize_component=$1
    kustomize_create_kustomization
    if [[ ! "x${kustomize_components}" == "x" ]]; then
        cd ${kustomization_directory} 1>&2 > /dev/null
        kustomize edit add component ${kustomize_component}
        kustomize_check_result $? "${kustomization_directory}/kustomization.yaml" "Error: could not add component $kustomize_component"
        cd ${kustomize_exec_dir}
    fi
}