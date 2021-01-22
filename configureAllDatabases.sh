echo "Starting Joe Burger Install"


databasewait=$1

echo "Executing Joe Burger Databases Install"
echo "---------------------------"

echo "Wait for Database : " $databasewait
echo ""

echo "Deleting Database Customer"
echo "--------------------"

kubectl delete -f 2.commons/secrets/postgres-secret-customer.yaml
kubectl delete -f 3.customer-postgres-microservice/local/postgres-customer-configmap.yaml
kubectl delete -f 3.customer-postgres-microservice/local/postgres-customer-initcreatetable-configmap.yaml
kubectl delete -f 3.customer-postgres-microservice/local/postgres-customer-runpostscript-configmap.yaml
kubectl delete -f 3.customer-postgres-microservice/local/postgres-customer-deployment.yaml

echo "Creating Database Customer"
echo "=========================="
echo ""

kubectl apply -f 2.commons/secrets/postgres-secret-customer.yaml
kubectl apply -f 3.customer-postgres-microservice/local/postgres-customer-configmap.yaml
kubectl apply -f 3.customer-postgres-microservice/local/postgres-customer-initcreatetable-configmap.yaml
kubectl apply -f 3.customer-postgres-microservice/local/postgres-customer-runpostscript-configmap.yaml
kubectl apply -f 3.customer-postgres-microservice/local/postgres-customer-deployment.yaml

if [ $databasewait -eq 1 ] 
then
  echo "Sleep for 5 secs for database to come up, dependency the services"
  sleep 5
fi

echo "Deleting Database Products"
echo "--------------------"


kubectl delete -f 2.commons/secrets/postgres-secret-products.yaml
kubectl delete -f 3.products-postgres-microservice/local/postgres-invoices-configmap.yaml
kubectl delete -f 3.products-postgres-microservice/local/postgres-invoices-initcreatetable-configmap.yaml
kubectl delete -f 3.products-postgres-microservice/local/postgres-invoices-runpostscript-configmap.yaml
kubectl delete -f 3.products-postgres-microservice/local/postgres-invoices-deployment.yaml

echo "Creating Database Products"
echo "=========================="
echo ""

kubectl apply -f 2.commons/secrets/postgres-secret-products.yaml
kubectl apply -f 3.products-postgres-microservice/local/postgres-products-configmap.yaml
kubectl apply -f 3.products-postgres-microservice/local/postgres-products-initcreatetable-configmap.yaml
kubectl apply -f 3.products-postgres-microservice/local/postgres-products-runpostscript-configmap.yaml
kubectl apply -f 3.products-postgres-microservice/local/postgres-products-deployment.yaml

if [ $databasewait -eq 1 ] 
then
  echo "Sleep for 5 secs for database to come up, dependency the services"
  sleep 5
fi

echo "Deleting Database Orders"
echo "--------------------"

kubectl delete -f 2.commons/secrets/postgres-secret-orders.yaml
kubectl delete -f 3.orders-postgres-microservice/local/postgres-orders-configmap.yaml
kubectl delete -f 3.orders-postgres-microservice/local/postgres-orders-initcreatetable-configmap.yaml
kubectl delete -f 3.orders-postgres-microservice/local/postgres-orders-runpostscript-configmap.yaml
kubectl delete -f 3.orders-postgres-microservice/local/postgres-orders-deployment.yaml

echo "Creating Database Orders"
echo "=========================="
echo ""

kubectl apply -f 2.commons/secrets/postgres-secret-orders.yaml
kubectl apply -f 3.orders-postgres-microservice/local/postgres-orders-configmap.yaml
kubectl apply -f 3.orders-postgres-microservice/local/postgres-orders-initcreatetable-configmap.yaml
kubectl apply -f 3.orders-postgres-microservice/local/postgres-orders-runpostscript-configmap.yaml
kubectl apply -f 3.orders-postgres-microservice/local/postgres-orders-deployment.yaml

if [ $databasewait -eq 1 ] 
then
  echo "Sleep for 5 secs for database to come up, dependency the services"
  sleep 5
fi

echo "Deleting Database Invoices"
echo "--------------------"

kubectl delete -f 2.commons/secrets/postgres-secret-invoices.yaml
kubectl delete -f 3.invoices-postgres-microservice/local/postgres-invoices-configmap.yaml
kubectl delete -f 3.invoices-postgres-microservice/local/postgres-invoices-initcreatetable-configmap.yaml
kubectl delete -f 3.invoices-postgres-microservice/local/postgres-invoices-runpostscript-configmap.yaml
kubectl delete -f 3.invoices-postgres-microservice/local/postgres-invoices-deployment.yaml

echo "Creating Database Invoices"
echo "=========================="
echo ""

kubectl apply -f 2.commons/secrets/postgres-secret-invoices.yaml
kubectl apply -f 3.invoices-postgres-microservice/local/postgres-invoices-configmap.yaml
kubectl apply -f 3.invoices-postgres-microservice/local/postgres-invoices-initcreatetable-configmap.yaml
kubectl apply -f 3.invoices-postgres-microservice/local/postgres-invoices-runpostscript-configmap.yaml
kubectl apply -f 3.invoices-postgres-microservice/local/postgres-invoices-deployment.yaml

