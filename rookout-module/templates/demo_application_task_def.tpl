[
  {
    "name": "${name}",
    "image": "rookout/tutorial-python:latest",
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
        "name": "ROOKOUT_CONTROLLER_HOST",
        "value": "${controller_host}"
      },
      {
        "name": "ROOKOUT_CONTROLLER_PORT",
        "value": "${controller_port}"
      },
      {
        "name": "ROOKOUT_REMOTE_ORIGIN",
        "value": "${remote_origin}"
      },
      {
        "name": "ROOKOUT_COMMIT",
        "value": "${commit}"
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
            "wget http://localhost:5000/ -O /dev/null || exit 1"
        ],
        "timeout": 5,
        "interval": 30,
        "startPeriod": null
    }
  }
]