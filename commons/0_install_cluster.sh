#!/bin/bash -v

PROJECT_ID=${GKE_PORJECT_ID};

# creating k8s cluster on GKE
gcloud container clusters create istio-demo --project=${PROJECT_ID} \
    --machine-type=n1-standard-2 \
    --num-nodes=2 \
    --zone europe-west1-b \
    --no-enable-legacy-authorization;

# add permissions to the GKE user
kubectl create clusterrolebinding cluster-admin-binding \
  --clusterrole=cluster-admin \
  --user="$(gcloud config get-value core/account)";

# istall istio
istioctl verify-install;

istioctl manifest apply --set profile=demo;
kubectl label namespace default istio-injection=enabled;

sleep 120;

CURRENT_LOCATION="$(dirname $0)/";
export UI_SERVICE="${CURRENT_LOCATION}../explorer-ui/"
export EVENT_SERVICE="${CURRENT_LOCATION}../event-service/"
export GROUND_EVENT_SERVICE="${CURRENT_LOCATION}../ground-event-service/"
export PLAYER_SERVICE="${CURRENT_LOCATION}../player-service/"

kubectl apply -f ${CURRENT_LOCATION}/redis.yaml
kubectl apply -f ${UI_SERVICE}/explorer-ui.yaml
kubectl apply -f ${EVENT_SERVICE}/event-service.yaml
kubectl apply -f ${GROUND_EVENT_SERVICE}/ground-event-service.yaml
kubectl apply -f ${PLAYER_SERVICE}/player-service.yaml
kubectl apply -f ${CURRENT_LOCATION}/gateway.yaml

kubectl -n istio-system get svc istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

