echo "Deleting Products Database"
echo "=========================="
echo ""

kubectl delete -f postgres-products-configmap.yaml
kubectl delete -f postgres-products-initcreatetable-configmap.yaml
kubectl delete -f postgres-products-runpostscript-configmap.yaml
kubectl delete -f postgres-products-deployment.yaml

echo "Creating Products Database"
echo "=========================="
echo ""

kubectl apply -f postgres-products-configmap.yaml
kubectl apply -f postgres-products-initcreatetable-configmap.yaml
kubectl apply -f postgres-products-runpostscript-configmap.yaml
kubectl apply -f postgres-products-deployment.yaml

