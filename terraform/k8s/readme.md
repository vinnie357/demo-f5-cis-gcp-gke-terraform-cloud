
# default cluster example
POST https://container.googleapis.com/v1beta1/projects/my-project-id/zones/us-central1-c/clusters
{
  "cluster": {
    "name": "cluster-1",
    "masterAuth": {
      "clientCertificateConfig": {}
    },
    "network": "projects/my-project-id/global/networks/default",
    "addonsConfig": {
      "httpLoadBalancing": {},
      "horizontalPodAutoscaling": {},
      "kubernetesDashboard": {
        "disabled": true
      },
      "istioConfig": {
        "disabled": true
      },
      "dnsCacheConfig": {}
    },
    "subnetwork": "projects/my-project-id/regions/us-central1/subnetworks/default",
    "nodePools": [
      {
        "name": "default-pool",
        "config": {
          "machineType": "n1-standard-1",
          "diskSizeGb": 100,
          "oauthScopes": [
            "https://www.googleapis.com/auth/devstorage.read_only",
            "https://www.googleapis.com/auth/logging.write",
            "https://www.googleapis.com/auth/monitoring",
            "https://www.googleapis.com/auth/servicecontrol",
            "https://www.googleapis.com/auth/service.management.readonly",
            "https://www.googleapis.com/auth/trace.append"
          ],
          "metadata": {
            "disable-legacy-endpoints": "true"
          },
          "imageType": "COS",
          "diskType": "pd-standard"
        },
        "initialNodeCount": 3,
        "autoscaling": {},
        "management": {
          "autoUpgrade": true,
          "autoRepair": true
        },
        "version": "1.14.10-gke.27"
      }
    ],
    "networkPolicy": {},
    "ipAllocationPolicy": {
      "useIpAliases": true
    },
    "masterAuthorizedNetworksConfig": {},
    "defaultMaxPodsConstraint": {
      "maxPodsPerNode": "110"
    },
    "authenticatorGroupsConfig": {},
    "privateClusterConfig": {},
    "databaseEncryption": {
      "state": "DECRYPTED"
    },
    "clusterTelemetry": {
      "type": "ENABLED"
    },
    "initialClusterVersion": "1.14.10-gke.27",
    "location": "us-central1-c"
  }
}