###################################################################################################
################################### K8's SECRETS ##################################################
###################################################################################################
/*
resource "kubernetes_secret" "docker" {
  metadata {
    name = "${var.prefix}-${var.project}-${var.namespace}-secret-ecrregistry"
    #namespace = "${var.namespace}"
  }

  data = {
    ".dockerconfigjson" = <<DOCKER
{
  "auths": {
    "${local.registry_server}": {
      "auth": "${base64encode("${var.registry_username}:${var.registry_password}")}"
    }
  }
}
DOCKER
  }

  type = "kubernetes.io/dockerconfigjson"
}
*/
###################################################################################################
################################### K8's DEPLOYMENTS ##############################################
###################################################################################################

resource "kubernetes_deployment" "weatherapi-mfe" {
  metadata {
    name = "${var.prefix}-${var.project}-${var.namespace}-deployment-weatherapi-mfe"
    labels = {
      App = "weatherapi-mfe"
    }
    #namespace = "${var.namespace}"
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "weatherapi-mfe"
      }
    }
    template {
      metadata {
        labels = {
          App = "weatherapi-mfe"
        }
      }
      spec {
       image_pull_secrets {
          name = "${var.prefix}-${var.project}-${var.namespace}-secret-ecrregistry"
        }      
        container {
          image = local.image_name
          name  = "${var.prefix}-${var.project}-${var.namespace}-pod-weatherapi-mfe"
          port {
            container_port = 80
          }                               
        }
      }
    }
  }
}

###################################################################################################
################################### K8's SERVICE ##################################################
###################################################################################################

resource "kubernetes_service" "weatherapi-mfe" {
  metadata {
    name = "${var.prefix}-${var.project}-${var.namespace}-service-weatherapi-mfe"
    #namespace = "${var.namespace}"
  }
  spec {
    selector = {
      App = kubernetes_deployment.weatherapi-mfe.spec.0.template.0.metadata[0].labels.App      
    }
    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}
