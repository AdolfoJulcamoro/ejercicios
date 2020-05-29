usage() {
  echo "Los parámetros de entrada: PROJECT_ID, SERVICE_ACCOUNT_EMAIL y SERVICE_ACCOUNT_JSON_PATH, en ese orden, son necesarios"
  exit 1
}

show_menu(){
    echo ""
    echo "----------------------------------------------"
    echo " ********** Opciones ********** "
    echo "----------------------------------------------"
    echo "[1] Desplegar Cluster"
    echo "[2] Destruir Cluster"
    echo "[3] Resultado"
    echo "[4] Salir"
    echo "----------------------------------------------"
}

read_option(){
    RED='\033[0;31m'
    NC='\033[0m' # No Color

    echo -n "Elige una opción [1-4]:"
    read option
    case $option in 
        1) echo ""
            if [ -d "${PATH_TERRAFORM}/.terraform" ] 
            then
                echo ""
                read -p "Terraform ya ha sido inicializado previamente. ¿Está seguro que desea ejecutar un nuevo lanzamiento (s/n)? \c" ans
                case ${ans:0:1} in 
                    n|N) echo "" ;;
                    *) echo ""; exit 0 ;;
                esac
            fi
            echo "Project Id: \c"
            read pi
            echo "Service Account (email): \c"
            read sae
            echo "Service Account Path (JSON): \c"
            read sap
            create $pi $sae "$sap"
            ;;
        2) destroy; break ;;
        3) salida; break ;;
        4) exit 0 ;;
        *) echo "${RED}Opción incorrecta";;
    esac
}

create(){
    echo "***** Validar datos de entrada"
    if [ ${#} -ne 3 ]; then
        usage
    fi

    echo "***** Estableciendo valores de entorno"
    export PROJECT_ID=$1
    export SERVICE_ACCOUNT_EMAIL=$2
    export SERVICE_ACCOUNT_JSON_PATH="$3"

    echo "***** Generando Public SSH"
    ssh-keygen -t rsa -f "$SSH_KEY_PATH" -C $USER_NAME

    echo "***** Conectando a Google Cloud Platform (GCP)"
    gcloud config set account ${SERVICE_ACCOUNT_EMAIL}
    gcloud auth activate-service-account --key-file="$SERVICE_ACCOUNT_JSON_PATH"
    #export CLOUDSDK_COMPUTE_ZONE="southamerica-east1-a"
    #export CLOUDSDK_COMPUTE_REGION="southamerica-east1"

    echo "***** Creando VM en GCP con Terraform"
    [ -d "$PATH_TERRAFORM" ] || mkdir "$PATH_TERRAFORM"
    cp "$PATH_BASE"/terraform_base/* "$PATH_TERRAFORM"
    cd "$PATH_TERRAFORM"
    sed -i 's@service_account_json_file_@'"$SERVICE_ACCOUNT_JSON_PATH"'@g' "$PATH_TERRAFORM"/variables.auto.tfvars
    sed -i 's/project_id_/'"$PROJECT_ID"'/g' "$PATH_TERRAFORM"/variables.auto.tfvars
    sed -i 's/service_account_email_/'"$SERVICE_ACCOUNT_EMAIL"'/g' "$PATH_TERRAFORM"/variables.auto.tfvars
    sed -i 's/ssh_username_/'"$USER_NAME"'/g' "$PATH_TERRAFORM"/variables.auto.tfvars
    sed -i 's@ssh_pub_key_path_@'"$SSH_PUB_KEY_PATH"'@g' "$PATH_TERRAFORM"/variables.auto.tfvars

    terraform init
    terraform plan
    terraform apply

    echo "***** Desplegando Jenkins"
    sleep 10
    export VM_IP=$(terraform output vm_ip)
    [ -d "$PATH_ANSIBLE" ] || mkdir "$PATH_ANSIBLE"
    cp -r "$PATH_BASE"/ansible_base/* "$PATH_ANSIBLE"
    cd "$PATH_ANSIBLE"
    sed -i 's/ansible_host_/'"$VM_IP"'/g' "$PATH_ANSIBLE"/inventory
    sed -i 's@ansible_ssh_private_key_file_@'"$SSH_KEY_PATH"'@g' "$PATH_ANSIBLE"/inventory

    ansible-playbook -i "$PATH_ANSIBLE"/inventory "$PATH_ANSIBLE"/jenkins.yaml -u $USER_NAME --private-key "$SSH_KEY_PATH"

    cd "$PATH_BASE"
}

destroy(){
    if [ ! -d "${PATH_TERRAFORM}/.terraform" ] 
    then
        echo ""
        echo "${RED}No existe el directorio .terraform${NC}, no se ejecutará el comando."
        echo ""
        exit 0;
    fi
    
    set +e
    cd "$PATH_TERRAFORM"
    terraform destroy
    cd "$PATH_BASE"
    rm -rf ansible terraform
}

salida(){
    GREEN='\033[0;32m'
    if [ ! -d "${PATH_TERRAFORM}" ] 
    then
        echo ""
        echo "${RED}No existe el directorio terraform${NC}, no se tiene un plan de terraform aún."
        echo ""
        exit 0;
    fi
    
    cd "$PATH_TERRAFORM"
    echo ""
    echo "${GREEN}Terraform Output${NC}"
    echo ""
    terraform output
    echo ""
    cd "$PATH_BASE"
}


set -e
export PATH_BASE="$PWD"
export PATH_ANSIBLE="$PATH_BASE"/ansible
export PATH_TERRAFORM="$PATH_BASE"/terraform
export SSH_KEY_PATH="${HOME}"/.ssh/id_rsa_jenkins
export SSH_PUB_KEY_PATH="${SSH_KEY_PATH}.pub"
export USER_NAME=`whoami`

show_menu
read_option

exit 0
