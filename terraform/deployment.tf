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
resource "kubernetes_secret" "auth0" {
  metadata {
    name = "${var.prefix}-${var.project}-${var.namespace}-secret-auth0"
    #namespace = "${var.namespace}"
  }

  data = {
  clientID = "${base64encode("${var.auth0_client_id}")}"
  clientSecret = "${base64encode("${var.auth0_client_secret}")}"
}	
}	

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

    type = "ClusterIP"    
  }
}	
  resource "kubernetes_ingress" "dev_api_ingress" {
  wait_for_load_balancer = true
  metadata {
    name = "dev-ingress"
    annotations = {
      "kubernetes.io/ingress.class" = "alb"
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "ip"
      "alb.ingress.kubernetes.io/certificate-arn" = "arn:aws:acm:us-west-2:921881026300:certificate/8d45ef30-d7b0-4700-8a0a-fde57cdec670"
      "alb.ingress.kubernetes.io/listen-ports": "[{\"HTTP\": 80}, {\"HTTPS\":443}]"
      "alb.ingress.kubernetes.io/actions.ssl-redirect": "{\"Type\": \"redirect\", \"RedirectConfig\": { \"Protocol\": \"HTTPS\", \"Port\": \"443\", \"StatusCode\": \"HTTP_301\"}}"
      "alb.ingress.kubernetes.io/auth-type" = "oidc"
      "alb.ingress.kubernetes.io/auth-idp-oidc": "{\"issuer\":\"https://dev-je0wn-4u.us.auth0.com/\",\"authorizationEndpoint\":\"https://dev-je0wn-4u.us.auth0.com/authorize\",\"tokenEndpoint\":\"https://dev-je0wn-4u.us.auth0.com/oauth/token\",\"userInfoEndpoint\":\"https://dev-je0wn-4u.us.auth0.com/userinfo\",\"secretName\":\"dax-coreinfra-dev-secret-auth0\"}" 
    }
  }
  spec {
    rule {
      http {        
	path {
          path = "/"
          backend {
            service_name = "dax-coreinfra-dev-service-weatherapi-mfe"
            service_port = 80
          }
	}	
	path {
          path = "/"		
	  backend {
	    service_name = "authenticate"
            service_port = "use-annotation"
	  }
	}	              
      }
    }
  }
}

