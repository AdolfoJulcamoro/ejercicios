#!/usr/bin/env bash
#sh ./build.sh helical-sanctum-277902 terraform@helical-sanctum-277902.iam.gserviceaccount.com /home/adolfo/kube/creds/serviceaccount.json
#export PROJECT_ID=helical-sanctum-277902
#export SERVICE_ACCOUNT_EMAIL=terraform@helical-sanctum-277902.iam.gserviceaccount.com
#export SERVICE_ACCOUNT_JSON_PATH=/home/adolfo/kube/creds/serviceaccount.json
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
    export REGION="us-central1"
    export ZONE="us-central1-a"
    export APP_NAME="mypythonapp"
    export SERVICE_NAME="mypythonapp"
    export IMAGE_NAME="gcr.io/${PROJECT_ID}/${APP_NAME}:v1"
    export PORT=80
    export TARGET_PORT=5000

    echo "***** Creando imagen de la applicación"
    docker build -t "${IMAGE_NAME}" "${PATH_APP}"

    echo "***** Conectando a Google Cloud Platform (GCP)"
    gcloud config set account ${SERVICE_ACCOUNT_EMAIL}
    gcloud auth activate-service-account --key-file="${SERVICE_ACCOUNT_JSON_PATH}"
    gcloud auth configure-docker

    echo "***** Subiendo la imagen: ${IMAGE_NAME} al registro de GCP"
    docker push "${IMAGE_NAME}"

    echo "***** Creando Cluster en GKE con Terraform"
    mkdir "$PATH_TERRAFORM"
    cp "$PATH_BASE"/terraform_base/* "$PATH_TERRAFORM"/
    rm "$PATH_TERRAFORM"/ingress.tf
    sed -i 's@service_account_json_file_@'"$SERVICE_ACCOUNT_JSON_PATH"'@g' "$PATH_TERRAFORM"/variables.auto.tfvars
    sed -i 's/project_id_/'"$PROJECT_ID"'/g' "$PATH_TERRAFORM"/variables.auto.tfvars
    sed -i 's/service_account_email_/'"$SERVICE_ACCOUNT_EMAIL"'/g' "$PATH_TERRAFORM"/variables.auto.tfvars
    sed -i 's/service_name_/'"$SERVICE_NAME"'/g' "$PATH_TERRAFORM"/variables.auto.tfvars
    sed -i 's/region_/'"$ZONE"'/g' "$PATH_TERRAFORM"/variables.auto.tfvars

    cd "$PATH_TERRAFORM"
    terraform init
    terraform plan
    terraform apply

    echo "***** Desplegando aplicación en GKE"
    gcloud container clusters get-credentials ${PROJECT_ID} --zone ${ZONE}
    kubectl create deployment ${APP_NAME} --image="${IMAGE_NAME}"
    kubectl expose deployment ${APP_NAME} --type=NodePort --port ${PORT} --target-port ${TARGET_PORT}
    echo "***** Despliegue completo"

    echo "***** Desplegando Ingress"
    sleep 10
    cp "$PATH_BASE"/terraform_base/ingress.tf "$PATH_TERRAFORM"/ingress.tf
    terraform init
    terraform plan
    terraform apply

    echo "***** Fin"
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
    rm -rf terraform
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
export PATH_APP="$PATH_BASE"/api
export PATH_TERRAFORM="$PATH_BASE"/terraform

show_menu
read_option

exit 0

#echo "***** Restaurando plantillas"
#sed -i 's@'"$SERVICE_ACCOUNT_JSON_PATH"'@service_account_json_file_@g' $PATH_TERRAFORM/variables.auto.tfvars
#sed -i 's/'"$PROJECT_ID"'/project_id_/g' $PATH_TERRAFORM/variables.auto.tfvars
#sed -i 's/'"$SERVICE_ACCOUNT_EMAIL"'/service_account_email_/g' $PATH_TERRAFORM/variables.auto.tfvars
#sed -i 's/'"$SERVICE_NAME"'/service_name_/g' $PATH_TERRAFORM/variables.auto.tfvars