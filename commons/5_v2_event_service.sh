#!/bin/bash

kubectl set image deployments/event-service event-service=sbishyr/event-service:2.0;
kubectl rollout status deployments/event-service;
# kubectl rollout undo deployments/event-service;
