#!/bin/bash


echo "Starting Joe Burger Delete"
echo "---------------------------"
echo ""

# Define the static variables

ELKNamespace=logging
elasticSearchHelmName=elasticsearch
kibanaHelmName=kibana
fluentdHelmName=fluentd
kopsName=epico

prometheusStackNamespace=monitoring
prometheusHelmHame=prometheus

ingressSleepInterval=60
databaseSleepInterval=5
EFKSleepInterval=60

kibanaBaseURL=kibana.joeburger.com.au
fluentdIndex=logstash

###########################################################
#
# AWSInstall : Used for AWS install
#
###########################################################

deleteKOPS(){

   echo "Delete KOPS"
   echo "-----------:
   
   export NAME=$kopsName.k8s.local
   kops delete cluster --name ${NAME} --yes
}






###########################################################
#
# Usage : How to use the program
#
###########################################################
usage(){

    echo "Joe Burger Kubernetes Delete Options "
    echo "------------------------------------------ "
    echo "Usage : " $0 "databasewait (1/0) ingresswait (1/0) --noprompt"
    echo "Usage : " $0 "databasewait (1/0) ingresswait (1/0)"
    echo ""
    echo "--help           - will display the install options"
    echo "1 (databasewait) - will wait 5 seconds after each database has been installed"
    echo "1 (ingresswait)  - will wait 60 seconds after the nginx ingress has been installed"
    echo "--noprompt       - will not prompt the user to install selected items"
    echo "--deleteKOPS     = deletes the KOPS Cluster"
    echo ""
    echo "Delete/Options"
    echo "1. Delete the Ingress"
    echo "2. Delete the Databases"
    echo "3  Delete the Applications"
    echo "4. Delete the Monitoring Component"
    echo "5. Delete the EFK Stack"
    echo "6. Delete Kong"
    echo ""
}

###########################################################
#
# deleteIngress : Installs all the ingress component
#                    into the Kubernetes environment
#
###########################################################

deleteIngress(){

	echo "Executing Ingress Delete"
	echo "-------------------------"
	
	
	kubectl delete -f 5.ingress/$environment/deploy.yaml
	
	if [ $ingresswait -eq 1 ] 
	then
	   echo "Sleeping for " $ingressSleepInterval " seconds for " $environment " ingress to come up ........."
	   sleep $ingressSleepInterval
	fi
	
	kubectl delete -f 5.ingress/secrets/ingress-customer-secret.yaml
	kubectl delete -f 5.ingress/secrets/ingress-products-secret.yaml
	kubectl delete -f 5.ingress/secrets/ingress-orders-secret.yaml
	kubectl delete -f 5.ingress/secrets/ingress-invoices-secret.yaml
	kubectl delete -f 5.ingress/app-rules/joeburger-customer-ingress.yaml
	kubectl delete -f 5.ingress/app-rules/joeburger-products-ingress.yaml
	kubectl delete -f 5.ingress/app-rules/joeburger-orders-ingress.yaml
	kubectl delete -f 5.ingress/app-rules/joeburger-invoices-ingress.yaml
	
	
	echo "-------------------------------------------"
	echo ""
}

###########################################################
#
# deleteDatabases : Deletes all the database components
#                    into the Kubernetes environment
#
###########################################################

deleteDatabases(){
	echo "Executing the Persistent Volumes Install"
	echo "----------------------------------------"
	
	
	kubectl delete -f 2.commons/storage/local/postgres-local-storage-customer.yaml
	kubectl delete -f 2.commons/storage/local/postgres-local-storage-products.yaml
	kubectl delete -f 2.commons/storage/local/postgres-local-storage-orders.yaml
	kubectl delete -f 2.commons/storage/local/postgres-local-storage-invoices.yaml
	
	echo "Executing Joe Burger Databases delete"
	echo "---------------------------"
	
	echo "Wait for Database : " $databasewait
	
	echo ""
	echo "Creating Database Customer"
	echo "=========================="
	echo ""
	
	kubectl delete -f 2.commons/secrets/postgres-secret-customer.yaml
	kubectl delete -f 3.customer-postgres-microservice/local/postgres-customer-configmap.yaml
	kubectl delete -f 3.customer-postgres-microservice/local/postgres-customer-initcreatetable-configmap.yaml
	kubectl delete -f 3.customer-postgres-microservice/local/postgres-customer-runpostscript-configmap.yaml
	kubectl delete -f 3.customer-postgres-microservice/local/postgres-customer-deployment.yaml
	
	if [ $databasewait -eq 1 ] 
	then
	  echo "Sleep for " $databaseSleepInterval " secs for database to come up, dependency the services"
	  sleep $databaseSleepInterval
	fi
	
	
	echo ""
	echo "Delete Database Products"
	echo "=========================="
	echo ""
	
	kubectl delete -f 2.commons/secrets/postgres-secret-products.yaml
	kubectl delete -f 3.products-postgres-microservice/local/postgres-products-configmap.yaml
	kubectl delete -f 3.products-postgres-microservice/local/postgres-products-initcreatetable-configmap.yaml
	kubectl delete -f 3.products-postgres-microservice/local/postgres-products-runpostscript-configmap.yaml
	kubectl delete -f 3.products-postgres-microservice/local/postgres-products-deployment.yaml
	
	if [ $databasewait -eq 1 ] 
	then
	  echo "Sleep for " $databaseSleepInterval " secs for database to come up, dependency the services"
	  sleep $databaseSleepInterval
	fi
	
	echo ""
	echo "Delete Database Orders"
	echo "=========================="
	echo ""
	
	kubectl delete -f 2.commons/secrets/postgres-secret-orders.yaml
	kubectl delete -f 3.orders-postgres-microservice/local/postgres-orders-configmap.yaml
	kubectl delete -f 3.orders-postgres-microservice/local/postgres-orders-initcreatetable-configmap.yaml
	kubectl delete -f 3.orders-postgres-microservice/local/postgres-orders-runpostscript-configmap.yaml
	kubectl delete -f 3.orders-postgres-microservice/local/postgres-orders-deployment.yaml
	
	if [ $databasewait -eq 1 ] 
	then
	  echo "Sleep for " $databaseSleepInterval " secs for database to come up, dependency the services"
	  sleep $databaseSleepInterval
	fi
	
	echo ""
	echo "Delete Database Invoices"
	echo "=========================="
	echo ""
	
	kubectl delete -f 2.commons/secrets/postgres-secret-invoices.yaml
	kubectl delete -f 3.invoices-postgres-microservice/local/postgres-invoices-configmap.yaml
	kubectl delete -f 3.invoices-postgres-microservice/local/postgres-invoices-initcreatetable-configmap.yaml
	kubectl delete -f 3.invoices-postgres-microservice/local/postgres-invoices-runpostscript-configmap.yaml
	kubectl delete -f 3.invoices-postgres-microservice/local/postgres-invoices-deployment.yaml
	
	
	if [ $databasewait -eq 1 ] 
	then
	  echo "Sleep for " $databaseSleepInterval " secs for database to come up, dependency the services"
	  sleep $databaseSleepInterval
	fi
}

###########################################################
#
# deleteApplications : Delete all the application components
#                    into the Kubernetes environment
#
###########################################################

deleteApplications(){

	echo ""
	echo "Delete Customer Deployment"
	echo "=========================="
	echo ""
	
	kubectl delete -f 2.commons/configmap/customer-configmap.yaml
	kubectl delete -f 4.customer-microservice/local/customer-developer.yaml
	
	
	echo ""
	echo "Delete Products Deployment"
	echo "=========================="
	echo ""
	
	kubectl delete -f 2.commons/configmap/products-configmap.yaml
	kubectl delete -f 4.products-microservice/local/products-developer.yaml
	
	echo ""
	echo "Delete Orders Deployment"
	echo "=========================="
	echo ""
	
	kubectl delete -f 2.commons/configmap/orders-configmap.yaml
	kubectl delete -f 4.orders-microservice/local/orders-developer.yaml
	
	
	echo ""
	echo "Delete Invoices Deployment"
	echo "=========================="
	echo ""
	
	kubectl delete -f 2.commons/configmap/invoices-configmap.yaml
	kubectl delete -f 4.invoices-microservice/local/invoices-developer.yaml

}


###########################################################
#
# deletePrometheusStack : 
#                     Delete all the application components
#                    into the Kubernetes environment
#
###########################################################

deletePrometheusStack(){

   echo ""
   echo "Delete the prometheus monitoring stack"
   echo "========================================""
   echo ""
   echo "Deleting the monitoring namespace"
   
   kubectl delete ns $prometheusStackNamespace
   
}

###########################################################
#
# DeleteEFKStack : Installs all the EFK components
#                    into the Kubernetes environment
#
###########################################################

deleteEFKStack(){

   echo ""
   echo "Deleting the logging stack"
   echo "==========================-"
   
   echo "Creating the logging namespace"
   kubectl delete ns $ELKNamespace
     

}


###########################################################
#
# createKong : Creates the Kong
#
###########################################################

createKong(){

   echo ""
   echo "Creating the Kong API Gateway"
   echo "============================="
   echo ""
   echo "Deleting the Kong Ingress Gateway ."
   kubectl delete ns kong
   
}

#####################################################
#
# Check for help option
#
#####################################################

if [ "$1" == "--help" ]; then
  usage
  exit 1
fi

#####################################################

#####################################################
#
# Check for awsInstall option
#
#####################################################

if [ "$1" == "--awsInstall" ]; then
  awsInstall
  exit 1
fi

####################################################

## Starting the main part of the script

if [ $# -eq 0 ]; then
    usage
    exit 1
fi

databasewait=$1
ingresswait=$2




if [ -z "$3" ]
then
  noprompt=no
else
  noprompt=no
  if [ "$3" == "--noprompt" ]; then
     noprompt=yes
  fi
fi

environment=""

# Check to see if you need to install the ingress component

echo ""
echo "0. What environment are you running ?"
select ma in "Minikube" "AWS"; do
    case $ma in
        Minikube ) environment=local; break;;
        AWS ) environment=aws; break;;
    esac
done


# Check to see if you need to install the ingress component

if [ "$noprompt" == "no" ]; then
	echo ""
	echo "1. Do you wish to delete the Ingress Component ?"
	select yn in "Yes" "No"; do
	    case $yn in
	        Yes ) deleteIngress; break;;
	        No ) break;;
	    esac
	done
else
  installIngress
fi

# Check to see if you need to delete the databases component

if [ "$noprompt" == "no" ]; then
	echo ""
	echo "2. Do you wish to delete the Databases ?"
	select yn in "Yes" "No"; do
	    case $yn in
	        Yes ) deleteDatabases; break;;
	        No ) break;;
	    esac
	done
else
  deleteDatabases
fi
  
# Check to see if you need to delete  the databases component

if [ "$noprompt" == "no" ]; then
	echo ""
	echo "3. Do you wish to delete the Applications ?"
	select yn in "Yes" "No"; do
	    case $yn in
	        Yes ) installApplications; break;;
	        No ) break;;
	    esac
	done
else
  deleteApplications
fi

# Check to see if you need to delete  the monitoring component

if [ "$noprompt" == "no" ]; then
	echo ""
	echo "4. Do you wish to delete the Monitoring Stack ?"
	select yn in "Yes" "No"; do
	    case $yn in
	        Yes ) deletePrometheusStack; break;;
	        No ) break;;
	    esac
	done
else
  deletePrometheusStack
fi

# Check to see if you need to delete the monitoring component

echo ""
echo "5. Do you wish to install the EFK ?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) deleteEFKStack; break;;
        No ) break;;
    esac
done


if [ "$noprompt" == "no" ]; then
    echo ""
	echo "6. Do you wish to delete Kong ?"
	select yn in "Yes" "No"; do
	    case $yn in
	        Yes ) deleteKong; break;;
	        No ) break;;
	    esac
	done
else
  deleteKong
fi




echo "Success"
exit 1
