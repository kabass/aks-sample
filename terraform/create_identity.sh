kubectl apply -f - <<EOF
          apiVersion: aadpodidentity.k8s.io/v1
          kind: AzureIdentity
          metadata:
              name: "poc-aks-pod-identity"                # The name of your Azure identity
          spec:
              type: 0                                     # Set type: 0 for managed service identity
              resourceID: /subscriptions/b257a86c-9b05-45ac-b405-69a297df5ee2/resourcegroups/poc_aks_rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/poc-aks-pod-identity
              clientID: "4f541a91-eefe-4bb3-939d-15c1b440153a"     # The clientId of the Azure AD identity that you created earlier
EOF

kubectl apply -f - <<EOF
          apiVersion: aadpodidentity.k8s.io/v1
          kind: AzureIdentityBinding
          metadata:
              name: poc-aks-pod-identity-binding
          spec:
              azureIdentity: "poc-aks-poc-identity"       # The name of your Azure identity
              selector: azure-pod-identity-binding-selector
EOF


kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: nginx-secrets-store-inline
  labels:
    aadpodidbinding: azure-pod-identity-binding-selector
spec:
  containers:
    - name: nginx
      image: nginx
      volumeMounts:
        - name: secrets-store-inline
          mountPath: "/mnt/secrets-store"
          readOnly: true
  volumes:
    - name: secrets-store-inline
      csi:
        driver: secrets-store.csi.k8s.io
        readOnly: true
        volumeAttributes:
          secretProviderClass: poc-aks-registry-secret
EOF