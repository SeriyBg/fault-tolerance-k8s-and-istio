#!/bin/bash

CURRENT_LOCATION="$(dirname $0)/";
kubectl apply -f ${UI_SERVICE}/explorer-ui.yaml
kubectl apply -f ${EVENT_SERVICE}/event-service.yaml
kubectl apply -f ${GROUND_EVENT_SERVICE}/ground-event-service.yaml
kubectl apply -f ${PLAYER_SERVICE}/player-service.yaml
kubectl apply -f ${CURRENT_LOCATION}/gateway.yaml