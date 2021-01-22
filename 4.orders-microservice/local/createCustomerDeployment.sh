echo "Deleting Orders Deployment"
echo "=========================="
echo ""

kubectl delete -f ../../2.commons/configmap/orders-configmap.yaml
kubectl delete -f ../../2.commons/secrets/postgres-secret-orders.yaml
kubectl delete -f orders-developer.yaml


echo "Creating Orders Deployment"
echo "=========================="
echo ""

kubectl apply -f ../../5.ingress-aws/local/deploy.yaml
kubectl apply -f ../../5.ingress-aws/joeburger-microservice-secret.yaml
kubectl apply -f ../../5.ingress-aws/joeburger-orders-ingress.yaml
kubectl apply -f ../../2.commons/configmap/orders-configmap.yaml
kubectl apply -f ../../2.commons/secrets/postgres-secret-orders.yaml
kubectl apply -f orders-developer.yaml


