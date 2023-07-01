# Define the Docker provider
provider "docker" {
  host = "tcp://localhost:2375"  
}

# Build the Docker image
resource "docker_image" "exocode" {
  name         = "exocode"  # Update with your Docker image name
  keep_locally = false
}

# Define the Kubernetes provider
provider "kubernetes" {
  config_path = "~/.kube/config"  
}

# Create the ConfigMap for environment variables
resource "kubernetes_config_map" "exocode_configmap" {
  metadata {
    name = "node-app-configmap"
  }
  data = {
    ENV_FILE_PATH = ".env.example" 
  }
}

# Create the Deployment
resource "kubernetes_deployment" "exocode_deployment" {
  metadata {
    name = "node-app-deployment"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "node-app"
      }
    }
    template {
      metadata {
        labels = {
          app = "node-app"
        }
      }
      spec {
        container {
          name  = "node-app"
          image = docker_image.exocode.latest
          ports {
            container_port = 3000
          }
          env_from {
            config_map_ref {
              name = kubernetes_config_map.exocode_configmap.metadata[0].name
            }
          }
        }
      }
    }
  }
}

# Create the Service
resource "kubernetes_service" "exocode_service" {
  metadata {
    name = "node-app-service"
  }
  spec {
    selector = {
      app = "node-app"
    }
    port {
      port        = 80
      target_port = 3000
    }
    type = "LoadBalancer"
  }
}
