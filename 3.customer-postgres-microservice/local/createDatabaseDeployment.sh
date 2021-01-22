echo "Deleting Customer Database"
echo "=========================="
echo ""

kubectl delete -f postgres-customer-configmap.yaml
kubectl delete -f postgres-customer-initcreatetable-configmap.yaml
kubectl delete -f postgres-customer-runpostscript-configmap.yaml
kubectl delete -f postgres-customer-deployment.yaml

echo "Creating Customer Database"
echo "=========================="
echo ""

kubectl apply -f postgres-customer-configmap.yaml
kubectl apply -f postgres-customer-initcreatetable-configmap.yaml
kubectl apply -f postgres-customer-runpostscript-configmap.yaml
kubectl apply -f postgres-customer-deployment.yaml

