helm repo add kong https://charts.konghq.com
helm repo update

helm install kong kong/kong

$ helm install kong kong/kong -f 8.Kong/values.yaml
NAME: kong
LAST DEPLOYED: Mon Jan 18 11:06:56 2021
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
To connect to Kong, please execute the following commands:

HOST=$(kubectl get svc --namespace default kong-kong-proxy -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
PORT=$(kubectl get svc --namespace default kong-kong-proxy -o jsonpath='{.spec.ports[0].port}')
export PROXY_IP=${HOST}:${PORT}
curl $PROXY_IP

Once installed, please follow along the getting started guide to start using
Kong: https://bit.ly/k4k8s-get-started


Kong Plugins :

grpc-web: true,
correlation-id: true,
pre-function: true,
cors: true,
rate-limiting: true,
loggly: true,
hmac-auth: true,
zipkin: true,
request-size-limiting: true,
azure-functions: true,
request-transformer: true,
oauth2: true,
response-transformer: true,
ip-restriction: true,
statsd: true,
jwt: true,
proxy-cache: true,
basic-auth: true,
key-auth: true,
http-log: true,
session: true,
datadog: true,
tcp-log: true,
prometheus: true,
post-function: true,
ldap-auth: true,
acl: true,
grpc-gateway: true,
file-log: true,
syslog: true,
udp-log: true,
response-ratelimiting: true,
aws-lambda: true,
bot-detection: true,
acme: true,
request-termination: true

How to test ?

a) Basic Auth

