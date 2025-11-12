#!/bin/bash

# Script to remove finalizers from Argo CD Application resources,
# allowing them to be garbage collected/deleted when stuck.
# This version dynamically fetches all Application resources in the target namespace.

NAMESPACE="argocd"
PATCH_PAYLOAD='{"metadata":{"finalizers":[]}}'

# 1. Fetch all Application names dynamically
echo "Fetching all Argo CD Application names in namespace: $NAMESPACE..."
# Uses jsonpath to extract a space-separated list of application names
APPLICATIONS=$(kubectl get applications -n "$NAMESPACE" -o jsonpath='{.items[*].metadata.name}' 2>/dev/null)

if [ -z "$APPLICATIONS" ]; then
    echo "❌ No Argo CD Applications found in namespace '$NAMESPACE'. Exiting."
    exit 1
fi

# Convert the space-separated string into an array
IFS=' ' read -r -a APPLICATION_ARRAY <<< "$APPLICATIONS"

echo "Found ${#APPLICATION_ARRAY[@]} applications to patch."
echo "Patch payload: $PATCH_PAYLOAD"
echo "----------------------------------------"

# 2. Iterate and patch each application
for APP in "${APPLICATION_ARRAY[@]}"; do
    echo "➡️ Patching application: $APP"
    # The '2>/dev/null' suppresses non-critical output/errors from kubectl for cleaner output
    kubectl patch application "$APP" -n "$NAMESPACE" -p "$PATCH_PAYLOAD" --type=merge 2>/dev/null
    
    # Check if the patch command was successful
    if [ $? -eq 0 ]; then
        echo "   ✅ Successfully patched $APP"
    else
        echo "   ⚠️ Failed to patch $APP (it might already be patched or deleted)."
    fi
done

echo "----------------------------------------"
echo "Patching complete. Applications should now be deletable."