[
  {
    "name": "${name}",
    "image": "rookout/data-on-prem:latest",
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
      },
      {
        "name": "ROOKOUT_TOKEN",
        "value": "${rookout_token}"
      }
      %{for key, value in additional_env_vars}
      ,{
        "name": "${key}",
        "value": "${value}"
      }
      %{endfor ~}
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
  }
]