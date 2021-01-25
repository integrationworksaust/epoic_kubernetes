#!/bin/bash


echo "Starting EPOIC Install"
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

export PATH=$PATH:/usr/local/bin

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
# AWSInstall : Used for AWS install
#
###########################################################

awsInstall(){

	
    echo "AWS Install."
    echo "---------------"
    echo ""
    echo "Dependency : AMI Linux instance with pre-installed AWS CLI tools"
    echo "1.  Install Kops"
    echo "2.  Install Kubectl"
    echo "3"  Create KOPS users and groups"
    
    
	curl -Lo kops https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
	chmod +x kops
	sudo mv kops /usr/local/bin/kops
	
	echo "Installing Kubectl"
	
	curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
	chmod +x ./kubectl
	sudo mv ./kubectl /usr/local/bin/kubectl
	
	echo "Installing Git"
	sudo yum install git -y
	sudo mkdir /u01
	sudo mkdir /u01/epoic
	sudo cd /u01/epoic
	sudo git clone https://github.com/integrationworksaust/epoic_kubernetes.git
	sudo cd /u01/epoic/epoic_kubernetes/
	sudo chmod u+x configureAll.sh
	
	echo "Creating kops user and groups"
	
	aws iam create-group --group-name kops
	
	aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess --group-name kops
	aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonRoute53FullAccess --group-name kops
	aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess --group-name kops
	aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/IAMFullAccess --group-name kops
	aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonVPCFullAccess --group-name kops
	
	aws iam create-user --user-name kops
	aws iam add-user-to-group --user-name kops --group-name kops
	aws iam create-access-key --user-name kops
	
	# configure the aws client to use your new IAM user
	aws configure           # Use your new access and secret key here
	aws iam list-users      # you should see a list of all your IAM users here
	
	# Because "aws configure" doesn't export these vars for kops to use, we export them now
	export AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id)
	export AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key)
	
	echo "Creating the KOPS S3 Bucket"
	aws s3api create-bucket --bucket epoic-kops-state-storage --region ap-southeast-2 --create-bucket-configuration LocationConstraint=ap-southeast-2
	
	export NAME=epoic.k8s.local
	export KOPS_STATE_STORE=s3://epoic-kops-state-storage
	
	echo "Creating KOPS configuration file for cluster"
	kops create cluster --zones ap-southeast-2a,ap-southeast-2b,ap-southeast-2c ${NAME}
	
	echo "Generate public and private key"
	ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa 
	
	echo "Installing public key in KOPS Cluster"
	kops create secret --name ${NAME} sshpublickey admin -i ~/.ssh/id_rsa.pub
	
	#kops edit cluster ${NAME} - Manual step at the moment
	
	echo "Verify changes of KOPS"
	kops get ig --name ${NAME}
	
	echo "Update changes of KOPS .. This will take a few minutes"
	kops update cluster ${NAME} --yes
	
	kops validate cluster
	
}

###########################################################
#
# postInstall : Only used if running minikube
#
###########################################################

postInstall(){

   echo "Post Install " $environment
   if [ "$environment" = "local" ] 
   then
   		echo "Running minikube tunnel for Ingress"
		minikube tunnel
   fi
}



###########################################################
#
# Usage : How to use the program
#
###########################################################
usage(){

    echo "Joe Burger Kubernetes Installation Options "
    echo "------------------------------------------ "
    echo "Usage : " $0 "databasewait (1/0) ingresswait (1/0) --noprompt"
    echo "Usage : " $0 "databasewait (1/0) ingresswait (1/0)"
    echo ""
    echo "--help           - will display the install options"
    echo "1 (databasewait) - will wait 5 seconds after each database has been installed"
    echo "1 (ingresswait)  - will wait 60 seconds after the nginx ingress has been installed"
    echo "--noprompt       - will not prompt the user to install selected items"
    echo "--awsInstall     - installs the necessary AWS components"
    echo "--deleteKOPS     = deletes the KOPS Cluster"
    echo ""
    echo "Install/Options"
    echo "1. Install the Ingress"
    echo "2. Install the Databases"
    echo "3  Install the Applications"
    echo "4. Install the Joe Burger Monitoring Component"
    echo "5. Install the EFK Stack"
    echo "6. Create Kibana Fluentd index"
    echo "7. Kong"
    echo "8. Minikube Tunnel ( Only for Minikube)"
    echo "(The minikube tunnel is used to associate a hosts file entry to the load balancer)"
    echo ""
}

###########################################################
#
# installIngress : Installs all the ingress component
#                    into the Kubernetes environment
#
###########################################################

installIngress(){

	echo "Executing Ingress Install"
	echo "-------------------------"
	
	
	kubectl apply -f 5.ingress/$environment/deploy.yaml
	
	if [ $ingresswait -eq 1 ] 
	then
	   echo "Sleeping for " $ingressSleepInterval " seconds for " $environment " ingress to come up ........."
	   sleep $ingressSleepInterval
	fi
	
	kubectl apply -f 5.ingress/secrets/ingress-customer-secret.yaml
	kubectl apply -f 5.ingress/secrets/ingress-products-secret.yaml
	kubectl apply -f 5.ingress/secrets/ingress-orders-secret.yaml
	kubectl apply -f 5.ingress/secrets/ingress-invoices-secret.yaml
	kubectl apply -f 5.ingress/app-rules/joeburger-customer-ingress.yaml
	kubectl apply -f 5.ingress/app-rules/joeburger-products-ingress.yaml
	kubectl apply -f 5.ingress/app-rules/joeburger-orders-ingress.yaml
	kubectl apply -f 5.ingress/app-rules/joeburger-invoices-ingress.yaml
	
	echo "*****************  There may be the following errors, failed calling webhook, *********************"
	echo "These should be safe to ignore, the ingress may still be configuring"
	
	echo "-------------------------------------------"
	echo ""
}

###########################################################
#
# installDatabases : Installs all the database components
#                    into the Kubernetes environment
#
###########################################################

installDatabases(){

	echo "Executing the Persistent Volumes Install"
	echo "----------------------------------------"
	
	
	if [ "$installCustomers" == "yes" ]; then
	    if [ "$environment" == "aws" ]; then
	       echo "kubectl apply -f 2.commons/storage/$environment/storage-class.yaml"
	       kubectl apply -f 2.commons/storage/$environment/storage-class.yaml
	    fi
		kubectl apply -f 2.commons/storage/$environment/postgres-$environment-storage-customers.yaml
    fi
	
	if [ "$installProducts" == "yes" ]; then
		kubectl apply -f 2.commons/storage/$environment/postgres-$environment-storage-products.yaml
	fi
		
    if [ "$installOrders" == "yes" ]; then
		kubectl apply -f 2.commons/storage/$environment/postgres-$environment-storage-orders.yaml
	fi
		
	if [ "$installInvoices" == "yes" ]; then
		kubectl apply -f 2.commons/storage/$environment/postgres-$environment-storage-invoices.yaml
	fi
	
	echo "Executing Joe Burger Databases Install"
	echo "---------------------------"
	
	echo "Wait for Database : " $databasewait
	
	if [ "$installCustomers" == "yes" ]; then
		echo ""
		echo "Creating Database Customer"
		echo "=========================="
		echo ""
		
		kubectl apply -f 2.commons/secrets/postgres-secret-customer.yaml
		kubectl apply -f 3.customer-postgres-microservice/$environment/postgres-customer-configmap.yaml
		kubectl apply -f 3.customer-postgres-microservice/$environment/postgres-customer-initcreatetable-configmap.yaml
		kubectl apply -f 3.customer-postgres-microservice/$environment/postgres-customer-runpostscript-configmap.yaml
		kubectl apply -f 3.customer-postgres-microservice/$environment/postgres-customer-deployment.yaml
		
		if [ $databasewait -eq 1 ] 
		then
		  echo "Sleep for " $databaseSleepInterval " secs for database to come up, dependency the services"
		  sleep $databaseSleepInterval
		fi
	fi	
	
	if [ "$installProducts" == "yes" ]; then
		echo ""
		echo "Creating Database Products"
		echo "=========================="
		echo ""
		
		kubectl apply -f 2.commons/secrets/postgres-secret-products.yaml
		kubectl apply -f 3.products-postgres-microservice/$environment/postgres-products-configmap.yaml
		kubectl apply -f 3.products-postgres-microservice/$environment/postgres-products-initcreatetable-configmap.yaml
		kubectl apply -f 3.products-postgres-microservice/$environment/postgres-products-runpostscript-configmap.yaml
		kubectl apply -f 3.products-postgres-microservice/$environment/postgres-products-deployment.yaml
		
		if [ $databasewait -eq 1 ] 
		then
		  echo "Sleep for " $databaseSleepInterval " secs for database to come up, dependency the services"
		  sleep $databaseSleepInterval
		fi
	fi
	
	
	 if [ "$installOrders" == "yes" ]; then
		echo ""
		echo "Creating Database Orders"
		echo "=========================="
		echo ""
		
		kubectl apply -f 2.commons/secrets/postgres-secret-orders.yaml
		kubectl apply -f 3.orders-postgres-microservice/$environment/postgres-orders-configmap.yaml
		kubectl apply -f 3.orders-postgres-microservice/$environment/postgres-orders-initcreatetable-configmap.yaml
		kubectl apply -f 3.orders-postgres-microservice/$environment/postgres-orders-runpostscript-configmap.yaml
		kubectl apply -f 3.orders-postgres-microservice/$environment/postgres-orders-deployment.yaml
		
		if [ $databasewait -eq 1 ] 
		then
		  echo "Sleep for " $databaseSleepInterval " secs for database to come up, dependency the services"
		  sleep $databaseSleepInterval
		fi
	fi
	
	
	if [ "$installInvoices" == "yes" ]; then	
		echo ""
		echo "Creating Database Invoices"
		echo "=========================="
		echo ""
		
		kubectl apply -f 2.commons/secrets/postgres-secret-invoices.yaml
		kubectl apply -f 3.invoices-postgres-microservice/$environment/postgres-invoices-configmap.yaml
		kubectl apply -f 3.invoices-postgres-microservice/$environment/postgres-invoices-initcreatetable-configmap.yaml
		kubectl apply -f 3.invoices-postgres-microservice/$environment/postgres-invoices-runpostscript-configmap.yaml
		kubectl apply -f 3.invoices-postgres-microservice/$environment/postgres-invoices-deployment.yaml
		
		
		if [ $databasewait -eq 1 ] 
		then
		  echo "Sleep for " $databaseSleepInterval " secs for database to come up, dependency the services"
		  sleep $databaseSleepInterval
		fi
	fi
		
}

###########################################################
#
# installApplications : Installs all the application components
#                    into the Kubernetes environment
#
###########################################################

installApplications(){

    if [ "$installCustomers" == "yes" ]; then
		echo ""
		echo "Creating Customer Deployment"
		echo "=========================="
		echo ""
		
		kubectl apply -f 2.commons/configmap/customer-configmap.yaml
		kubectl apply -f 4.customer-microservice/$environment/customer.yaml
	fi
	
	
	if [ "$installProducts" == "yes" ]; then
		echo ""
		echo "Creating Products Deployment"
		echo "=========================="
		echo ""
		
		kubectl apply -f 2.commons/configmap/products-configmap.yaml
		kubectl apply -f 4.products-microservice/$environment/products.yaml
	fi
	
		
	if [ "$installOrders" == "yes" ]; then
		echo ""
		echo "Creating Orders Deployment"
		echo "=========================="
		echo ""
		
		kubectl apply -f 2.commons/configmap/orders-configmap.yaml
		kubectl apply -f 4.orders-microservice/$environment/orders.yaml
	fi
	
	
	if [ "$installInvoices" == "yes" ]; then
		echo ""
		echo "Creating Invoices Deployment"
		echo "=========================="
		echo ""
		
		kubectl apply -f 2.commons/configmap/invoices-configmap.yaml
		kubectl apply -f 4.invoices-microservice/$environment/invoices.yaml
	fi

}


###########################################################
#
# installPrometheusStack : 
#                     Installs all the application components
#                    into the Kubernetes environment
#
###########################################################

installPrometheusStack(){

   echo ""
   echo "Creating the prometheus monitoring stack"
   echo "========================================""
   echo ""
   echo "Creating the monitoring namespace"
   
   kubectl create ns $prometheusStackNamespace
   
   echo "helm install $prometheusHelmHame prometheus-community/kube-prometheus-stack"
   helm install $prometheusHelmHame prometheus-community/kube-prometheus-stack -f 6.prometheus-stack/values.yaml -n $prometheusStackNamespace
}

###########################################################
#
# installEFKStack : Installs all the EFK components
#                    into the Kubernetes environment
#
###########################################################

installEFKStack(){

   echo ""
   echo "Creating the logging stack"
   echo "==========================-"
   
   echo "Creating the logging namespace"
   kubectl create ns $ELKNamespace
     
   echo "Creating elasticsearch, kibana and fluentd .........  This may take some time "
     
   helm install $elasticSearchHelmName elastic/elasticsearch -f 7.EFK/elasticsearch/values.yaml -n $ELKNamespace
   helm install $kibanaHelmName elastic/kibana -f 7.EFK/kibana/values.yaml -n $ELKNamespace
   helm install $fluentdHelmName stable/fluentd -f 7.EFK/fluentd/values.yaml -n $ELKNamespace

}

###########################################################
#
# createFluentdIndex : Creates the Fluentd index
#
###########################################################

createFluentdIndex(){

   echo ""
   echo "Creating the Fluentd Index"
   ecjo "--------------------------:
   echo "Sleeping for " $EFKSleepInterval " to allow for EFK stack to come up "
   
   sleep $EFKSleepInterval
   
   #curl -X POST $kibanaBaseURL/api/saved_objects/index-pattern/$fluentdIndex -H 'kbn-xsrf: true' H 'Content-Type: application/json'
   echo curl -X POST $kibanaBaseURL/api/saved_objects/index-pattern/$fluentdIndex -H 'kbn-xsrf: true' H 'Content-Type: application/json'
   curl -X POST $kibanaBaseURL/api/saved_objects/index-pattern/$fluentdIndex -H 'kbn-xsrf: true' -H 'Content-Type: application/json' -d' {"attributes": {"title": "logstash-*","timeFieldName": "@timestamp"}}'

   echo ""
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
   echo "Installing the Kong Ingress Gateway ."
   kubectl apply -f 8.Kong/deploy.yaml
   
   echo "Creating the API Key Plugin ........."
   
   kubectl apply -f 8.Kong/plugins/apikey-auth.yaml
   
   echo ""
   echo "Creating the secrets ................"
   
   kubectl apply -f 8.Kong/plugins/apikey-auth.yaml
   
   kubectl apply -f 8.Kong/secret/customers-authapi-key.yaml
   kubectl apply -f 8.Kong/secret/invoices-authapi-key.yaml
   kubectl apply -f 8.Kong/secret/orders-authapi-key.yaml
   kubectl apply -f 8.Kong/secret/products-authapi-key.yaml
   
   echo ""
   echo "Creating the Ingress ................"   
   echo ""
   
   kubectl apply -f 8.Kong/ingress/customers-apikey-auth.yaml
   kubectl apply -f 8.Kong/ingress/invoices-apikey-auth.yaml
   kubectl apply -f 8.Kong/ingress/orders-apikey-auth.yaml
   kubectl apply -f 8.Kong/ingress/products-apikey-auth.yaml
   
   echo ""
   echo "Creating the Consumers .............."
   echo ""
   
   kubectl apply -f 8.Kong/consumer/customers-consumer-apikey.yaml
   kubectl apply -f 8.Kong/consumer/invoices-consumer-apikey.yaml
   kubectl apply -f 8.Kong/consumer/orders-consumer-apikey.yaml
   kubectl apply -f 8.Kong/consumer/products-consumer-apikey.yaml
   
   echo ""
   echo "Completed the Kong installation ......"
   
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
installCustomers="yes"
installInvoices="yes"
installProducts="yes"
installOrders="yes"

if [ "$noprompt" == "no" ]; then
	echo ""
	echo "1. Do you wish to install Customers ?"
	select yn in "Yes" "No"; do
	    case $yn in
	        Yes ) installCustomers="yes"; break;;
	        No ) installCustomers="no";break;;
	    esac
	done
fi

if [ "$noprompt" == "no" ]; then
	echo ""
	echo "1. Do you wish to install Products ?"
	select yn in "Yes" "No"; do
	    case $yn in
	        Yes ) installProducts="yes"; break;;
	        No ) installProducts="no";break;;
	    esac
	done
fi

if [ "$noprompt" == "no" ]; then
	echo ""
	echo "1. Do you wish to install Orders ?"
	select yn in "Yes" "No"; do
	    case $yn in
	        Yes ) installOrders="yes"; break;;
	        No ) installOrders="no";break;;
	    esac
	done
fi

if [ "$noprompt" == "no" ]; then
	echo ""
	echo "1. Do you wish to install Invoices ?"
	select yn in "Yes" "No"; do
	    case $yn in
	        Yes ) installInvoices="yes"; break;;
	        No ) installInvoices="no";break;;
	    esac
	done
fi

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
	echo "1. Do you wish to install/update the Ingress Component ?"
	select yn in "Yes" "No"; do
	    case $yn in
	        Yes ) installIngress; break;;
	        No ) break;;
	    esac
	done
else
  installIngress
fi

# Check to see if you need to install/update the databases component

if [ "$noprompt" == "no" ]; then
	echo ""
	echo "2. Do you wish to install the Databases ?"
	select yn in "Yes" "No"; do
	    case $yn in
	        Yes ) installDatabases; break;;
	        No ) break;;
	    esac
	done
else
  installDatabases
fi
  
# Check to see if you need to install  the databases component

if [ "$noprompt" == "no" ]; then
	echo ""
	echo "3. Do you wish to install the Applications ?"
	select yn in "Yes" "No"; do
	    case $yn in
	        Yes ) installApplications; break;;
	        No ) break;;
	    esac
	done
else
  installApplications
fi

# Check to see if you need to install  the monitoring component

if [ "$noprompt" == "no" ]; then
	echo ""
	echo "4. Do you wish to install the Monitoring Stack ?"
	select yn in "Yes" "No"; do
	    case $yn in
	        Yes ) installPrometheusStack; break;;
	        No ) break;;
	    esac
	done
else
  installPrometheusStack
fi

# Check to see if you need to install the monitoring component

echo ""
echo "5. Do you wish to install the EFK ?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) installEFKStack; break;;
        No ) break;;
    esac
done

if [ "$noprompt" == "no" ]; then
    echo ""
	echo "6. Do you wish to create the Fluentd index ?"
	select yn in "Yes" "No"; do
	    case $yn in
	        Yes ) createFluentdIndex; break;;
	        No ) break;;
	    esac
	done
else
  createFluentdIndex
fi	

if [ "$noprompt" == "no" ]; then
    echo ""
	echo "7. Do you wish to install Kong ?"
	select yn in "Yes" "No"; do
	    case $yn in
	        Yes ) createKong; break;;
	        No ) break;;
	    esac
	done
else
  createKong
fi

if [ "$noprompt" == "no" ]; then
    echo ""
	echo "7. Do you wish to do the PostInstall ?"
	select yn in "Yes" "No"; do
	    case $yn in
	        Yes ) postInstall; break;;
	        No ) break;;
	    esac
	done
else
   postInstall
fi


echo "Success"
exit 1
