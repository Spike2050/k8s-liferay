helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace

helm repo add mariadb-operator https://helm.mariadb.com/mariadb-operator
helm repo update
helm install mariadb-operator-crds mariadb-operator/mariadb-operator-crds
helm install mariadb-operator mariadb-operator/mariadb-operator --namespace mariadb-operator --create-namespace

helm repo add elastic https://helm.elastic.co
helm repo update
# elastic CRDs should not be installed by helm, ignore the warnings during installation
kubectl apply -f https://download.elastic.co/downloads/eck/3.2.0/crds.yaml
helm install eck-operator elastic/eck-operator --namespace elastic-operator --create-namespace --set installCRDs=false
