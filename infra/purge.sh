kubectl delete namespace kafka &
kubectl get pv | cut -d ' ' -f 1 | tail -n +2 | xargs kubectl delete pv

