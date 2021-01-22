echo "Deleting Orders Database"
echo "=========================="
echo ""

kubectl delete -f postgres-orders-configmap.yaml
kubectl delete -f postgres-orders-initcreatetable-configmap.yaml
kubectl delete -f postgres-orders-runpostscript-configmap.yaml
kubectl delete -f postgres-orders-deployment.yaml

echo "Creating Orders Database"
echo "=========================="
echo ""

kubectl apply -f postgres-orders-configmap.yaml
kubectl apply -f postgres-orders-initcreatetable-configmap.yaml
kubectl apply -f postgres-orders-runpostscript-configmap.yaml
kubectl apply -f postgres-orders-deployment.yaml

