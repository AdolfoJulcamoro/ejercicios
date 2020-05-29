# Ejercicios

Ejercicios de Infraestructua as code para aplicar sobre [Google Cloud Platform](https://cloud.google.com/) (GCP):

* **jenkins** - Despliega un cluster con Terraform y, usando [Ansible](https://www.ansible.com/), se despliega una VM, con Centos 7 para alojar a [Jenkins](https://www.jenkins.io/). El despliegue de Jenkins contiene una [Shared Library](https://www.jenkins.io/doc/book/pipeline/shared-libraries/) y un [Job](https://www.jenkins.io/doc/book/pipeline/) que compila una aplicación Java usando Maven

* **python** - Despliega un cluster con [Terraform](https://www.terraform.io/), instala una pequeña aplicación python y la expone con Ingress


### Prerequisitos

Para ejecutar los ejercicios es necesario contar con:
* Una cuenta en GCP
* Un projecto en GCP
* Las siguientes API's habilitadas en el proyecto: Compute Engine, Kubernetes Engine y Cloud Build 
* Un [Service Account](https://cloud.google.com/iam/docs/service-accounts) con los roles necesarios para manipular el proyecto (Kubernetes Engine Admin, Project Editor y Storage Admin)


### Instalación
* Clona el repositorio
* Ambas carpetas (python y jenkins) contienen una shell que orquesta todo el proceso de despliegue, conviértelas en ejecutables:
```shell
$ chmod +x build.sh 
```

## Ejecutando los ejercicios

Ingresa a la carpeta del ejercicio que deseas probar y ejecuta *build.sh*. Un menú te indicará las opciones disponibles

> Python
```shell
$ ./build.sh

----------------------------------------------
 ********** Opciones ********** 
----------------------------------------------
[1] Desplegar Cluster
[2] Destruir Cluster
[3] Resultado
[4] Salir
----------------------------------------------
Elige una opción [1-4]:
```

* La primera opción (*Desplegar cluster*) hace uso de terraform para desplegar un cluster en GCP, también instala una aplicación python y la expone con Ingress
* La segunda opción destruye el ambiente creado en GCP
* La tercera opción muestra el resultado de *Terraform output*


> Jenkins
```shell
$ ./build.sh

----------------------------------------------
 ********** Opciones ********** 
----------------------------------------------
[1] Desplegar Cluster
[2] Destruir Cluster
[3] Resultado
[4] Salir
----------------------------------------------
Elige una opción [1-4]:
```

* La primera opción (*Desplegar cluster*) hace uso de terraform para desplegar un cluster en GCP. Luego, usando Ansible, despliega una VM, Jenkins, crea una Shared Library y un Job que la consume.
* La segunda opción destruye el ambiente creado en GCP
* La tercera opción muestra el resultado de *Terraform output*
