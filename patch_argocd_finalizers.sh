#!/bin/bash

# Script to remove finalizers from Argo CD Application resources,
# allowing them to be garbage collected/deleted when stuck.

NAMESPACE="argocd"
PATCH_PAYLOAD='{"metadata":{"finalizers":[]}}'

# List of Argo CD Applications to patch:
APPLICATIONS=(
    "app-of-apps"
    "aws-load-balancer-controller"
    "eck-operator"
    "eck-stack"
    "filebeat-eck"
    "prometheus-stack"
    "prometheus-stack-crds"
    "website-application"
)

echo "Attempting to patch ${#APPLICATIONS[@]} applications in namespace $NAMESPACE..."
echo "Patch payload: $PATCH_PAYLOAD"
echo "----------------------------------------"

for APP in "${APPLICATIONS[@]}"; do
    echo "Patching application: $APP"
    kubectl patch application "$APP" -n "$NAMESPACE" -p "$PATCH_PAYLOAD" --type=merge
done

echo "----------------------------------------"
echo "Patching complete. Applications should now be deletable."