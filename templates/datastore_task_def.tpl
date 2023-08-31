[
  {
    "name": "${name}",
    "image": "${datastore_image}:${datastore_version}",
    "cpu": ${cpu},
    "memory": ${memory},
    "memoryReservation": ${memory},
    "essential": true,
    %{ if deploy_dynatrace_agent }
    "mountPoints": [
        {
            "sourceVolume": "oneagent",
            "containerPath": "/opt/dynatrace/oneagent",
            "readOnly": false
        }
    ],
    "dependsOn": [
        {
            "containerName": "install-oneagent",
            "condition": "COMPLETE"
        }
    ],
    %{ endif ~}
    "portMappings": [
      {
        "containerPort": ${port}
      }
    ],
    "environment": [
      %{ if deploy_dynatrace_agent }
      {
          "name": "LD_PRELOAD",
          "value": "/opt/dynatrace/oneagent/agent/lib64/liboneagentproc.so"
      },
      %{ endif ~}
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
      },
      {
        "name": "ROOKOUT_DOP_LOGGING_TOKEN",
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
            "wget http://localhost:4009/healthz -O /dev/null || exit 1"
        ],
        "timeout": 5,
        "interval": 30,
        "startPeriod": null
    }
  }
  %{ if deploy_dynatrace_agent }
  ,{
    "name": "install-oneagent",
    "image": "alpine:3",
    "cpu": 0,
    "portMappings": [],
    "essential": false,
    "entryPoint": [
        "/bin/sh",
        "-c"
    ],
    "command": [
        "ARCHIVE=$(mktemp) && wget -O $ARCHIVE \"$DT_API_URL/v1/deployment/installer/agent/unix/paas/latest?Api-Token=$DT_PAAS_TOKEN&$DT_ONEAGENT_OPTIONS\" && unzip -o -d /opt/dynatrace/oneagent $ARCHIVE && rm -f $ARCHIVE"
    ],
    "environment": [
        {
            "name": "DT_PAAS_TOKEN",
            "value": "${dynatrace_pass_token}"
        },
        {
            "name": "DT_ONEAGENT_OPTIONS",
            "value": "flavor=musl&include=all"
        },
        {
            "name": "DT_API_URL",
            "value": "https://ozg05024.live.dynatrace.com/api"
        }
    ],
    "environmentFiles": [],
    "mountPoints": [
      {
          "sourceVolume": "oneagent",
          "containerPath": "/opt/dynatrace/oneagent",
          "readOnly": false
      }
    ],
    "volumesFrom": [],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "${log_group}",
            "awslogs-region": "${aws_region}",
            "awslogs-stream-prefix": "${log_stream}"
        }
    }
  }
  %{ endif ~}
]