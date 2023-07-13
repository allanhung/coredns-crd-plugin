# compile your own coredns-crd-plugin
```bash
git clone -b ns-server-resolution https://github.comm/allanhung/coredns-crd-plugin
cd coredns-crd-plugin
docker build -t allanhung/k8s_crd:v0.0.10 .
docker push allanhung/k8s_crd:v0.0.10 .
```
# install k8gb from helm chart
```bash
helm repo update k8gb
helm pull --untar k8gb/k8gb
cd k8gb && patch -p1 --no-backup < ../helm.patch && cd ..
```
## us cluster
```bash
helm template --release-name k8gb -f values.yaml -f values.us.yaml --set coredns.image.repository=allanhung/k8s_crd --set coredns.image.tag=v0.0.10 k8gb/ 
```
## eu cluster
```bash
helm template --release-name k8gb -f values.yaml -f values.eu.yaml --set coredns.image.repository=allanhung/k8s_crd --set coredns.image.tag=v0.0.10 k8gb/ 
```

# test with podinfo application
```bash
helm repo add podinfo https://stefanprodan.github.io/podinfo
helm repo update podinfo
```
## us cluster
```bash
helm template --release-name podinfo --set ui.message="us" podinfo/podinfo
```
## eu cluster
```bash
helm template --release-name podinfo --set ui.message="eu" podinfo/podinfo
```
## create gslb resource in each cluster
```bash
cat << EOF | kubectl apply -f -
apiVersion: k8gb.absa.oss/v1beta1
kind: Gslb
metadata:
  name: podinfo
spec:
  ingress:
    ingressClassName: nginx
    rules:
      - host: podinfo.gslb.example.com
        http:
          paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: podinfo # This should point to Service name of testing application
                port:
                  name: http

  strategy:
    type: roundRobin
EOF
```
# create ns record and a record for coredns server
```bash
gslb.example.com.            60      IN    NS      gslb-ns-us-gslb.example.com.
gslb.example.com.            60      IN    NS      gslb-ns-eu-gslb.example.com.
gslb-ns-us-gslb.example.com. 60      IN    A       <coredns_ip_in_us>
gslb-ns-eu-gslb.example.com. 60      IN    A       <coredns_ip_in_eu>
```
