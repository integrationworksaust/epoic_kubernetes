echo "Deleting Customer Deployment"
echo "=========================="
echo ""

kubectl delete -f ../../2.commons/configmap/customer-configmap.yaml
kubectl delete -f ../../2.commons/secrets/postgres-secret-customer.yaml
kubectl delete -f customer-developer.yaml


echo "Creating Customer Deployment"
echo "=========================="
echo ""

kubectl apply -f ../../5.ingress-aws/local/deploy.yaml
kubectl apply -f ../../5.ingress-aws/joeburger-microservice-secret.yaml
kubectl apply -f ../../5.ingress-aws/joeburger-customer-ingress.yaml
kubectl apply -f ../../2.commons/configmap/customer-configmap.yaml
kubectl apply -f ../../2.commons/secrets/postgres-secret-customer.yaml
kubectl apply -f customer-developer.yaml


