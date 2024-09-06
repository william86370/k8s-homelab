


PASSWORD=$(kubectl -n rook-ceph get secret rook-ceph-dashboard-password -o jsonpath="{.data.password}" | base64 --decode)

echo "Username: admin"
echo "Password: ${PASSWORD}"

kubectl port-forward -n rook-ceph svc/rook-ceph-mgr-dashboard 8070:7000

