echo "Deleting Invoices Database"
echo "=========================="
echo ""

kubectl delete -f postgres-invoices-configmap.yaml
kubectl delete -f postgres-invoices-initcreatetable-configmap.yaml
kubectl delete -f postgres-invoices-runpostscript-configmap.yaml
kubectl delete -f postgres-invoices-deployment.yaml

echo "Creating invoices Database"
echo "=========================="
echo ""

kubectl apply -f postgres-invoices-configmap.yaml
kubectl apply -f postgres-invoices-initcreatetable-configmap.yaml
kubectl apply -f postgres-invoices-runpostscript-configmap.yaml
kubectl apply -f postgres-invoices-deployment.yaml

