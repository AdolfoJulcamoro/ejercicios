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
export SSH_KEY_PATH=/home/adolfo/.ssh/id_rsa_jenkins
export SSH_PUB_KEY_PATH="${SSH_KEY_PATH}.pub"
export USER_NAME=`whoami`

show_menu
read_option

exit 0

#Habilita las API de Compute Engine, Kubernetes Engine y Cloud Build
#org.jenkinsci.plugins.workflow.libs.GlobalLibraries.xml

#credentials        = "/home/adolfo/kube/creds/serviceaccount.json"
#project_id         = "helical-sanctum-277902"
#region             = "southamerica-east1"
#zones              = ["southamerica-east1-a", "southamerica-east1-b", "southamerica-east1-c"]
#service_account    = "terraform@helical-sanctum-277902.iam.gserviceaccount.com"
#vm_name            = "vm-jenkins"
#machine_type       = "f1-micro"
#ssh_username       = "adolfo"
#ssh_pub_key_path   = "~/.ssh/id_rsa_jenkins.pub"

#remove with:\r\n  
#ssh-keygen -f "/home/adolfo/.ssh/known_hosts" -R "35.198.8.45"
#ssh-keygen -f "/home/adolfo/.ssh/known_hosts" -R "34.95.201.51"
#ssh-keygen -f "/home/adolfo/.ssh/known_hosts" -R "35.198.46.114"
#ssh-keygen -f "/home/adolfo/.ssh/known_hosts" -R "34.95.180.25"
#ssh-keygen -f "/home/adolfo/.ssh/known_hosts" -R "34.95.224.23"
#ssh-keygen -f "/home/adolfo/.ssh/known_hosts" -R "34.95.201.51"
#ssh-keygen -f "/home/adolfo/.ssh/known_hosts" -R "35.198.46.114"
#ssh-keygen -f "/home/adolfo/.ssh/known_hosts" -R "34.95.203.195"
#ssh-keygen -f "/home/adolfo/.ssh/known_hosts" -R "35.198.8.45"
#ssh-keygen -f "/home/adolfo/.ssh/known_hosts" -R "34.95.224.23"
#ssh-keygen -f "/home/adolfo/.ssh/known_hosts" -R "34.95.180.25"
#ssh-keygen -f "/home/adolfo/.ssh/known_hosts" -R "35.198.8.45"
#ssh-keygen -f "/home/adolfo/.ssh/known_hosts" -R "35.198.46.114"
#ssh-keygen -f "/home/adolfo/.ssh/known_hosts" -R "34.95.201.51"
#ssh-keygen -f "/home/adolfo/.ssh/known_hosts" -R "34.95.203.195"
#ssh-keygen -f "/home/adolfo/.ssh/known_hosts" -R "104.197.158.127"
#ssh-keygen -f "/home/adolfo/.ssh/known_hosts" -R "104.197.158.127"
#ssh-keygen -f "/home/adolfo/.ssh/known_hosts" -R "35.239.209.189"
#ssh-keygen -f "/home/adolfo/.ssh/known_hosts" -R "104.197.158.127"
#ssh-keygen -f "/home/adolfo/.ssh/known_hosts" -R "35.239.209.189"
#ssh-keygen -f "/home/adolfo/.ssh/known_hosts" -R "104.197.158.127"
#ssh-keygen -f "/home/adolfo/.ssh/known_hosts" -R "34.68.117.62"

#Library
# 	Name																																(firstlibrary)
# 	Default version																											(master)
#Currently maps to revision: db71c0ea113d2affed16320e8569f87e9fe6c635
# 	Load implicitly																											(false)		
# 	Allow default version to be overridden															(true)
# 	Include @Library changes in job recent changes											(true)
#Retrieval method
# Modern SCM																														(true)
#Source Code Management
# Git																																	(chequed)
# 	Project Repository	https://github.com/AdolfoJulcamoro/sharedlibhellomaven.git
# 	Credentials	
#
#- none -
# 
# 	Behaviors	
#Within Repository
#Discover branches




#[julcamorosm@vm-jenkins jenkins]$ ll
#total 116
#drwxr-xr-x.  3 jenkins jenkins   26 May 28 22:48 caches
#-rw-r--r--.  1 jenkins jenkins  439 May 28 23:50 com.cloudbees.hudson.plugins.folder.config.AbstractFolderConfiguration.xml
#-rw-r--r--.  1 jenkins jenkins 1673 May 28 23:50 config.xml
#-rw-r--r--.  1 jenkins jenkins  156 May 28 22:37 hudson.model.UpdateCenter.xml
#-rw-r--r--.  1 jenkins jenkins  443 May 28 23:50 hudson.plugins.git.GitSCM.xml
#-rw-r--r--.  1 jenkins jenkins  370 May 28 22:37 hudson.plugins.git.GitTool.xml
#-rw-r--r--.  1 jenkins jenkins  271 May 28 23:50 hudson.tasks.Mailer.xml
#-rw-r--r--.  1 jenkins jenkins   76 May 28 23:50 hudson.tasks.Shell.xml
#-rw-r--r--.  1 jenkins jenkins  216 May 28 23:50 hudson.triggers.SCMTrigger.xml
#-rw-------.  1 jenkins jenkins 1712 May 28 22:34 identity.key.enc
#drwxrwxr-x.  2 jenkins jenkins    6 May 28 22:35 init.groovy.d
#-rw-r--r--.  1 jenkins jenkins    5 May 28 22:34 jenkins.install.InstallUtil.lastExecVersion
#-rw-r--r--.  1 jenkins jenkins    5 May 28 22:34 jenkins.install.UpgradeWizard.state
#-rw-r--r--.  1 jenkins jenkins  159 May 28 23:50 jenkins.model.ArtifactManagerConfiguration.xml
#-rw-r--r--.  1 jenkins jenkins  253 May 28 23:50 jenkins.model.GlobalBuildDiscarderConfiguration.xml
#-rw-r--r--.  1 jenkins jenkins  266 May 28 23:50 jenkins.model.JenkinsLocationConfiguration.xml
#-rw-r--r--.  1 jenkins jenkins   86 May 28 23:50 jenkins.security.ResourceDomainConfiguration.xml
#-rw-r--r--.  1 jenkins jenkins  171 May 28 22:34 jenkins.telemetry.Correlator.xml
#drwxr-xr-x.  3 jenkins jenkins   23 May 28 22:38 jobs
#drwxr-xr-x.  3 jenkins jenkins   19 May 28 22:34 logs
#-rw-r--r--.  1 jenkins jenkins  907 May 28 22:37 nodeMonitors.xml
#drwxr-xr-x.  2 jenkins jenkins    6 May 28 22:34 nodes
#-rw-r--r--.  1 jenkins jenkins  272 May 28 23:50 org.jenkinsci.plugins.docker.workflow.declarative.GlobalConfig.xml
#-rw-r--r--.  1 jenkins jenkins   46 May 28 22:55 org.jenkinsci.plugins.workflow.flow.FlowExecutionList.xml
#-rw-r--r--.  1 jenkins jenkins  153 May 28 23:50 org.jenkinsci.plugins.workflow.flow.GlobalDefaultFlowDurabilityLevel.xml
#-rw-r--r--.  1 jenkins jenkins 1861 May 28 23:50 org.jenkinsci.plugins.workflow.libs.GlobalLibraries.xml
#-rw-r--r--.  1 jenkins jenkins  236 May 28 23:50 org.jenkins.plugins.lockableresources.LockableResourcesManager.xml
#drwxr-xr-x. 58 jenkins jenkins 8192 May 28 22:37 plugins
#-rw-r--r--.  1 jenkins jenkins  129 May 28 22:56 queue.xml
#-rw-r--r--.  1 jenkins jenkins  129 May 28 22:37 queue.xml.bak
#-rw-r--r--.  1 jenkins jenkins   64 May 28 22:34 secret.key
#-rw-r--r--.  1 jenkins jenkins    0 May 28 22:34 secret.key.not-so-secret
#drwx------.  4 jenkins jenkins 4096 May 28 22:48 secrets
#drwxr-xr-x.  2 jenkins jenkins  100 May 28 22:37 updates
#drwxr-xr-x.  2 jenkins jenkins   24 May 28 22:34 userContent
#drwxr-xr-x.  3 jenkins jenkins   56 May 28 22:34 users
#drwxr-xr-x.  2 jenkins jenkins    6 May 28 22:37 workflow-libs
#drwxr-xr-x.  5 jenkins jenkins   66 May 28 22:48 workspace
#[julcamorosm@vm-jenkins jenkins]$ 