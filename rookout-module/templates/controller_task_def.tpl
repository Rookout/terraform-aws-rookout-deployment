[
  {
    "name": "${name}",
    "image": "032275105219.dkr.ecr.eu-west-1.amazonaws.com/controller:latest",
    "cpu": ${cpu},
    "memory": ${memory},
    "memoryReservation": ${memory},
    "essential": true,
    "portMappings": [
      {
        "containerPort": ${port}
      }
    ],
    "environment": [
      {
        "name": "ROOKOUT_DOP_NO_SSL_VERIFY",
        "value": "${dop_no_ssl_verify}"
      },
      {
        "name": "ONPREM_ENABLED",
        "value": "${onprem_enabled}"
      },
      {
        "name": "ROOKOUT_CONTROLLER_SERVER_MODE",
        "value": "${controller_server_mode}"
      },
      {
        "name": "ROOKOUT_ENFORCE_TOKEN",
        "value": "true"
      }
    ],
    "secrets": [
      {
        "name": "ROOKOUT_TOKEN",
        "valueFrom": "${rookout_token_arn}"
      }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "${log_group}",
            "awslogs-region": "${aws_region}",
            "awslogs-stream-prefix": "${log_stream}"
        }
    },
    "healthCheck": {
        "retries": 3,
        "command": [
            "CMD-SHELL",
            "wget http://localhost:4009/healthz -O /dev/null || exit 1"
        ],
        "timeout": 5,
        "interval": 30,
        "startPeriod": null
    }
  }
]