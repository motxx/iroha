#!/bin/bash

SOURCE=$(dirname $(dirname "$0"))
DOCKER=${SOURCE}/docker
PROJECT=iroha

zero="/tmp/zero.block"

ZERO64=$(printf "%064d" 0)
ZERO128=$(printf "%0128d" 0)

NODE=$(docker-machine active)

docker service scale ${PROJECT}_node=$1 ${PROJECT}_postgres=$1 ${PROJECT}_redis=$1

touch ${zero}
echo "{
    \"hash\": \"20e1a6f78251ddf3f2e9820dbb6b8d0a8f1944f71198f00a7c521533eb8c6118\",
    \"signatures\": [
        {
            \"pubkey\": \"${ZERO64}\",
            \"signature\": \"${ZERO128}\"
        }
    ],
    \"created_ts\": 0,
    \"height\": 1,
    \"prev_hash\": \"${ZERO64}\",
    \"txs_number\": $(($1+1)),
    \"merkle_root\": \"${ZERO64}\",
    \"transactions\": [" >> ${zero}

i=1
for node in $(docker service ps --no-trunc iroha_node --format "{{.Name}}.{{.ID}}")
do
    echo "Adding node ${node}"

    echo "{
            \"signatures\": [
                {
                    \"pubkey\": \"${ZERO64}\",
                    \"signature\": \"${ZERO128}\"
                }
            ],
            \"created_ts\": 0,
            \"creator_account_id\": \"\",
            \"tx_counter\": 0,
            \"commands\": [
                {
                    \"command_type\": \"AddPeer\",
                    \"address\": \"${node}:10001\",
                    \"peer_key\": \"$(printf "%064d" ${i})\"
                }
            ]
        }," >> ${zero}
    i=$((i+1))
done

echo "{
            \"signatures\": [
                {
                    \"pubkey\": \"${ZERO64}\",
                    \"signature\": \"${ZERO128}\"
                }
            ],
            \"created_ts\": 0,
            \"creator_account_id\": \"\",
            \"tx_counter\": 0,
            \"commands\": [
                {
                    \"command_type\": \"CreateDomain\",
                    \"domain_name\": \"test\"
                },
                {
                    \"command_type\": \"CreateAsset\",
                    \"asset_name\": \"coin\",
                    \"domain_id\": \"test\",
                    \"precision\": 2
                },
                {
                    \"command_type\": \"CreateAccount\",
                    \"domain_id\": \"test\",
                    \"account_name\": \"admin\",
                    \"pubkey\": \"$(printf "%064d" 1)\"
                },
                {
                    \"command_type\": \"CreateAccount\",
                    \"domain_id\": \"test\",
                    \"account_name\": \"test\",
                    \"pubkey\": \"$(printf "%064d" 2)\"
                },
                {
                    \"command_type\": \"SetAccountPermissions\",
                    \"account_id\": \"admin@test\",
                    \"new_permissions\": {
                        \"add_signatory\": false,
                        \"can_transfer\": true,
                        \"create_accounts\": false,
                        \"create_assets\": false,
                        \"create_domains\": false,
                        \"issue_assets\": true,
                        \"read_all_accounts\": true,
                        \"remove_signatory\": false,
                        \"set_permissions\": true,
                        \"set_quorum\": false
                    }
                }
            ]
        }
    ]
}" >> ${zero}

while read -r node
do
    args=(${node})

    eval $(docker-machine env ${args[0]})

    echo "Waiting for ${args[1]}"

    until [ "$(docker inspect -f {{.State.Running}} ${args[1]})" == "true" ]; do
        sleep 0.1;
    done;

    echo "${args[1]} container is running"

    until docker exec ${args[1]} pg_isready
    do
        sleep 0.1;
    done;

    echo "${args[1]} PostgreSQL is ready"
done < <(docker service ps --no-trunc iroha_postgres --format "{{.Node}} {{.Name}}.{{.ID}}")

eval $(docker-machine env ${NODE})

i=0
while read -r node
do
    args=(${node})

    conf="{
      \"block_store_path\" : \"/tmp/block_store/\",
      \"torii_port\" : 50051,
      \"pg_opt\" : \"host=${args[2]} port=5432 user=root password=password\",
      \"redis_host\" : \"${args[3]}\",
      \"redis_port\" : 6379
    }"

    eval $(docker-machine env ${args[0]})

    echo "Waiting for ${args[1]}"

    until [ "$(docker inspect -f {{.State.Running}} ${args[1]})" == "true" ]; do
        sleep 0.1;
    done;

    echo "${args[1]} container is running"

    docker exec -i ${args[1]} /bin/bash << EOD
    mkdir /tmp/block_store
    echo '${conf}' > /tmp/iroha.conf
    echo '$(cat ${zero})' > /tmp/zero.block
EOD
    docker exec -d ${args[1]} /bin/bash -c "irohad --config /tmp/iroha.conf --genesis_block /tmp/zero.block --peer_number ${i} > iroha.log"
    i=$((i+1))
done < <(paste -d ' ' <(docker service ps --no-trunc iroha_node --format "{{.Node}} {{.Name}}.{{.ID}}") <(docker service ps --no-trunc iroha_postgres --format "{{.Name}}.{{.ID}}") <(docker service ps --no-trunc iroha_redis --format "{{.Name}}.{{.ID}}"))

eval $(docker-machine env ${NODE})

rm ${zero}
