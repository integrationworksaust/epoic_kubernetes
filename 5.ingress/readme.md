## How to generate auth from command line

1. Create the htpasswd file

2. kubectl create secret generic customer-auth --from-file=customer-auth

secret/basic-auth created

kubectl get secret basic-auth -0 yaml