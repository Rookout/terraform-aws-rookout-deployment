# This deployment will use pre-imported arn of certificate in ACM ( for that needed Body, private key and chain )
# that will be used by datastore, therefore CNAME record of certificate's domain should be recored at your's DNS provider.
# controller will be deployed with internal load balancer. 
module "rookout" {
    source  = "Rookout/rookout-deployment/aws"
        # version = x.y.z
    
    datastore_acm_certificate_arn = "PRE_IMPORTED_ACM_CERTIFICATE_ARN"
    rookout_token = "YOUR_TOKEN"
}

output "rookout" {
    value = module.rookout
}