# Deploy Vault Service Broker on Kubernetes

https://github.com/hashicorp/vault-service-broker

## Deploy the service broker

Create a secret:

```
VAULT_ADDR=
VAULT_TOKEN=
SECURITY_USER_NAME=
SECURITY_USER_PASSWORD=

kubectl create -n vault-broker secret generic vault-broker \
  --from-literal=vault-addr=${VAULT_ADDR} \
  --from-literal=vault-token=${VAULT_TOKEN} \
  --from-literal=username=${SECURITY_USER_NAME} \
  --from-literal=password=${SECURITY_USER_PASSWORD} \
  --dry-run -oyaml > manifest/secret.yml
```

Deploy a broker using [kapp](https://github.com/k14s/kapp):

```
kapp deploy -a vault-broker -f manifest -c
```

Check the status:

```
kapp -a vault-broker inspect -t
```


Check the logs:

```
kapp -a vault-broker logs -f
```


## Use the service broker

Check the marketplace:

```
$ svcat marketplace
       CLASS        PLANS             DESCRIPTION            
+-----------------+--------+--------------------------------+
  hashicorp-vault   shared   HashiCorp Vault Service Broker
```

Create a service instance:

```
$ svcat provision demo-instance --class hashicorp-vault --plan shared
  Name:        demo-instance                                
  Namespace:   default                                      
  Status:                                                   
  Class:       0654695e-0760-a1d4-1cad-5dd87b75ed99         
  Plan:        0654695e-0760-a1d4-1cad-5dd87b75ed99.shared  

Parameters:
  No parameters defined
```

Create a service binding:

```
$ svcat bind demo-instance --name demo-binding
  Name:        demo-binding   
  Namespace:   default        
  Status:                     
  Secret:      demo-binding   
  Instance:    demo-instance  

Parameters:
  No parameters defined
```

View the details of a service instance: 

```
$ svcat describe instance demo-instance
  Name:        demo-instance                                                                      
  Namespace:   default                                                                            
  Status:      Ready - The instance was provisioned successfully @ 2019-06-24 08:04:18 +0000 UTC  
  Class:       0654695e-0760-a1d4-1cad-5dd87b75ed99                                               
  Plan:        0654695e-0760-a1d4-1cad-5dd87b75ed99.shared                                        

Parameters:
  No parameters defined

Bindings:
      NAME       STATUS  
+--------------+--------+
  demo-binding   Ready 
```

Check a new secret is created in k8s:

```
$ kubectl get secret
NAME                  TYPE                                  DATA   AGE
default-token-hdrng   kubernetes.io/service-account-token   3      160d
demo-binding          Opaque                                4      58s
```

```
$ kubectl get secret demo-binding -o yaml
apiVersion: v1
data:
  address: aHR0cHM6Ly92YXVsdC5kZXYuYm9zaC50b2t5by8=
  auth: eyJhY2Nlc3NvciI6IkJ2elY5ZGZKa2daVGNpdHJzZU1HVFRaVyIsInRva2VuIjoicy5MZ1ZuZk11Q1gwZHRSbDNKVFBOQTVZb2sifQ==
  backends: eyJnZW5lcmljIjpbImNmLzliZTY3ZTNmLTk2NTgtMTFlOS1iNjM5LTMyMmUwNzMxNmYyNi9zZWNyZXQiXSwidHJhbnNpdCI6WyJjZi85YmU2N2UzZi05NjU4LTExZTktYjYzOS0zMjJlMDczMTZmMjYvdHJhbnNpdCJdfQ==
  backends_shared: eyJhcHBsaWNhdGlvbiI6ImNmLy9zZWNyZXQiLCJvcmdhbml6YXRpb24iOiJjZi9mYjMxZWJhNy0xOTlmLTExZTktYWQ1My0zYTA3ZDNmYWY0MzUvc2VjcmV0Iiwic3BhY2UiOiJjZi82MGIyMTFjMi0xN2RiLTExZTktYmYyOS0wNjVhYTVlNjYyMzAvc2VjcmV0In0=
kind: Secret
metadata:
  creationTimestamp: "2019-06-24T08:18:20Z"
  name: demo-binding
  namespace: default
  ownerReferences:
  - apiVersion: servicecatalog.k8s.io/v1beta1
    blockOwnerDeletion: true
    controller: true
    kind: ServiceBinding
    name: demo-binding
    uid: 9fe67717-9658-11e9-b639-322e07316f26
  resourceVersion: "21250838"
  selfLink: /api/v1/namespaces/default/secrets/demo-binding
  uid: a0691974-9658-11e9-a27e-06c9beee8654
type: Opaque
```

Checkt the corresponding secrets are created in Vault: 

```
$ vault secrets list
Path                                                Type         Accessor              Description
----                                                ----         --------              -----------
cf/60b211c2-17db-11e9-bf29-065aa5e66230/secret/     generic      generic_70e4e53e      n/a
cf/9be67e3f-9658-11e9-b639-322e07316f26/secret/     generic      generic_66a397e6      n/a
cf/9be67e3f-9658-11e9-b639-322e07316f26/transit/    transit      transit_5174d654      n/a
cf/broker/                                          generic      generic_329ececa      n/a
cf/fb31eba7-199f-11e9-ad53-3a07d3faf435/secret/     generic      generic_1e57fab7      n/a
cubbyhole/                                          cubbyhole    cubbyhole_1c55ef23    per-token private secret storage
identity/                                           identity     identity_4c73170b     identity store
sys/                                                system       system_827865b2       system endpoints used for control, policy and debugging
```

Delete a service binding:

```
svcat unbind demo-instance --name demo-binding
```

Delete a service instance:

```
svcat deprovision demo-instance
```

See also https://svc-cat.io/docs/cli/
