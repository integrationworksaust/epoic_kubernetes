echo "Deleting Invoices Deployment"
echo "=========================="
echo ""

kubectl delete -f ../../2.commons/configmap/invoices-configmap.yaml
kubectl delete -f ../../2.commons/secrets/postgres-secret-invoices.yaml
kubectl delete -f invoices-developer.yaml


echo "Creating Invoices Deployment"
echo "=========================="
echo ""

kubectl apply -f ../../5.ingress-aws/local/deploy.yaml
kubectl apply -f ../../5.ingress-aws/joeburger-microservice-secret.yaml
kubectl apply -f ../../5.ingress-aws/joeburger-invoices-ingress.yaml
kubectl apply -f ../../2.commons/configmap/invoices-configmap.yaml
kubectl apply -f ../../2.commons/secrets/postgres-secret-invoices.yaml
kubectl apply -f invoices-developer.yaml


