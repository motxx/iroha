#!/bin/bash

SOURCE=$(dirname $(dirname "$0"))
DOCKER=${SOURCE}/docker
PROJECT=iroha

zero="/tmp/zero.block"

ZERO64=$(printf "%064d" 0)
ZERO128=$(printf "%0128d" 0)

docker-compose -f ${DOCKER}/docker-compose.yml -p ${PROJECT} --project-directory ${SOURCE} scale node=$1 postgres=$1 redis=$1

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

for i in `seq 1 $1`
do
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
                    \"address\": \"${PROJECT}_node_$i:10001\",
                    \"peer_key\": \"$(printf "%064d" $i)\"
                }
            ]
        }," >> ${zero}
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

for i in `seq 1 $1`
do
    conf="{
      \"block_store_path\" : \"/tmp/block_store/\",
      \"torii_port\" : 50051,
      \"pg_opt\" : \"host=${PROJECT}_postgres_$i port=5432 user=root password=password\",
      \"redis_host\" : \"${PROJECT}_redis_$i\",
      \"redis_port\" : 6379
    }"

    docker exec -i ${PROJECT}_node_$i /bin/bash << EOD
    mkdir /tmp/block_store
    echo '${conf}' > /tmp/iroha.conf
    echo '$(cat ${zero})' > /tmp/zero.block
EOD
    docker exec -d ${PROJECT}_node_$i /bin/bash -c "irohad --config /tmp/iroha.conf --genesis_block /tmp/zero.block --peer_number $(($i-1)) > iroha.log"
done

rm ${zero}
