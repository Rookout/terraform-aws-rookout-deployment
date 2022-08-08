package test

import (
	"fmt"
	"testing"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func BasicHttpTestController(t *testing.T, terraformOptions *terraform.Options) {
	controllerURL := terraform.Output(t, terraformOptions, "controller_dns")
	url := fmt.Sprintf("%s", controllerURL)

	expectedReturnValueCTRL := "Rookout Service [OK] - connect to this endpoint using our SDK. More information is available on https://docs.rookout.com"
	http_helper.HttpGetWithRetry(t, url, nil, 200, expectedReturnValueCTRL, 5, 60*time.Second)
}

func BasicHttpTestDatastore(t *testing.T, terraformOptions *terraform.Options) {
	datastoreURL := terraform.Output(t, terraformOptions, "datastore_dns")
	url := fmt.Sprintf("%s", datastoreURL)

	expectedReturnValueDS := "Rookout Datastore [OK] - finish the installation by following the instructions at https://docs.rookout.com/docs/dop-install/#next-steps"
	http_helper.HttpGetWithRetry(t, url, nil, 200, expectedReturnValueDS, 10, 60*time.Second)
}

func TestDeafultDeployment(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../example/rookout_default",
		Vars: map[string]interface{}{
			"environment": "rookout1",
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	BasicHttpTestController(t, terraformOptions)

	BasicHttpTestDatastore(t, terraformOptions)

}

// func TestDomainInternalCtrl(t *testing.T) {
// 	t.Parallel()

// 	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
// 		TerraformDir: "../example/rookout_domain_internal_ctrl",
// 		Vars: map[string]interface{}{
// 			"environment": "rookout2",
// 		},
// 	})

// 	defer terraform.Destroy(t, terraformOptions)

// 	terraform.InitAndApply(t, terraformOptions)

// 	BasicHttpTestDatastore(t, terraformOptions)

// }
