[
  {
    "name": "${name}",
    "image": "032275105219.dkr.ecr.eu-west-1.amazonaws.com/data-on-prem:latest",
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
        "name": "ROOKOUT_DOP_SERVER_MODE",
        "value": "${datastore_server_mode}"
      },
      {
        "name": "ROOKOUT_DOP_IN_MEMORY_DB",
        "value": "${datastore_in_memory_db}"
      },
      {
        "name": "ROOKOUT_DOP_PORT",
        "value": "${port}"
      }
    ],
    "secrets": [
      {
        "name": "ROOKOUT_DOP_LOGGING_TOKEN",
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
            "wget http://localhost:8080/healthz -O /dev/null || exit 1"
        ],
        "timeout": 5,
        "interval": 30,
        "startPeriod": null
    }
  },
  {
    "name": "rookout-datastore-envoy",
    "image": "840364872350.dkr.ecr.eu-west-1.amazonaws.com/aws-appmesh-envoy:v1.22.2.0-prod",
    "essential": true,
    "networkMode": "awsvpc",
    "cpu": ${cpu},
    "memory": ${memory},
    "environment": [
      {
        "name": "APPMESH_RESOURCE_ARN",
        "value": "${virtual_node_arn}"
      }
    ],
    "portMappings": [
      {
        "hostPort": 9901,
        "protocol": "tcp",
        "containerPort": 9901
      }
    ],
    "healthCheck": {
      "command": [
        "CMD-SHELL",
        "curl -s http://localhost:9901/server_info | grep state | grep -q LIVE"
      ],
      "startPeriod": 10,
      "interval": 5,
      "timeout": 2,
      "retries": 3
    },
    "user": "1337",
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${log_group}",
        "awslogs-region": "${aws_region}",
        "awslogs-stream-prefix": "${log_stream_envoy}"
      }
    },
    "ulimits": [
      {
        "softLimit": 15000,
        "hardLimit": 15000,
        "name": "nofile"
      }
    ]
  }
]