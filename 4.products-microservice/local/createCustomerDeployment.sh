echo "Deleting Products Deployment"
echo "=========================="
echo ""

kubectl delete -f ../../2.commons/configmap/products-configmap.yaml
kubectl delete -f ../../2.commons/secrets/postgres-secret-products.yaml
kubectl delete -f products-developer.yaml


echo "Creating Products Deployment"
echo "=========================="
echo ""

kubectl apply -f ../../5.ingress-aws/local/deploy.yaml
kubectl apply -f ../../5.ingress-aws/joeburger-microservice-secret.yaml
kubectl apply -f ../../5.ingress-aws/joeburger-products-ingress.yaml
kubectl apply -f ../../2.commons/configmap/products-configmap.yaml
kubectl apply -f ../../2.commons/secrets/postgres-secret-products.yaml
kubectl apply -f products-developer.yaml


