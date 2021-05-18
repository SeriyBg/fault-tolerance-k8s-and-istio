#!/bin/bash -v

# creating k8s cluster on GKE
gcloud container clusters create istio-demo --num-nodes=2;
gcloud container clusters get-credentials istio-demo;

# add permissions to the GKE user
kubectl create clusterrolebinding cluster-admin-binding \
  --clusterrole=cluster-admin \
  --user="$(gcloud config get-value core/account)";

# istall istio
istioctl install --set profile=demo -y;
istioctl verify-install;
kubectl label namespace default istio-injection=enabled --overwrite=true;

sleep 120;

export CURRENT_LOCATION="$(dirname $0)/";
export UI_SERVICE="${CURRENT_LOCATION}../explorer-ui/"
export EVENT_SERVICE="${CURRENT_LOCATION}../event-service/"
export GROUND_EVENT_SERVICE="${CURRENT_LOCATION}../ground-event-service/"
export PLAYER_SERVICE="${CURRENT_LOCATION}../player-service/"

# install hazelcast
helm repo add hazelcast https://hazelcast-charts.s3.amazonaws.com/
helm repo update
helm install hz-hazelcast hazelcast/hazelcast

kubectl apply -f ${UI_SERVICE}/explorer-ui.yaml
kubectl apply -f ${EVENT_SERVICE}/event-service.yaml
kubectl apply -f ${GROUND_EVENT_SERVICE}/ground-event-service.yaml
kubectl apply -f ${PLAYER_SERVICE}/player-service.yaml
kubectl apply -f ${CURRENT_LOCATION}/gateway.yaml

kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.9/samples/addons/grafana.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.9/samples/addons/jaeger.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.9/samples/addons/prometheus.yaml

kubectl -n istio-system get svc istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
