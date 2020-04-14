#!/bin/bash
# allows tradational HA with googlelb target pools
echo -n "Enter your bigip username and press [ENTER]: "
read admin_username
echo -n "Enter your bigip password and press [ENTER]: "
read -s admin_password
echo ""
CREDS="$admin_username:$admin_password"
# as3
as3Url="/mgmt/shared/appsvcs/declare"
as3CheckUrl="/mgmt/shared/appsvcs/info"
as3TaskUrl="/mgmt/shared/appsvcs/task"
#
# make as3 files
cp gcplb_as3.json.src bigip1_gcplb_as3.json
cp gcplb_as3.json.src bigip2_gcplb_as3.json
# mgmt
bigip1MgmtIp=$(gcloud compute instances list --filter name:cis-demo-cis --format json | jq .[0] | jq .networkInterfaces | jq -r .[1].accessConfigs[0].natIP)
bigip2MgmtIp=$(gcloud compute instances list --filter name:cis-demo-cis --format json | jq .[1] | jq .networkInterfaces | jq -r .[1].accessConfigs[0].natIP)
# external ip
bigip1ExternalSelfIp=$(gcloud compute instances list --filter name:cis-demo-cis --format json | jq .[0] | jq .networkInterfaces | jq -r .[0].networkIP)
bigip2ExternalSelfIp=$(gcloud compute instances list --filter name:cis-demo-cis --format json | jq .[1] | jq .networkInterfaces | jq -r .[0].networkIP)
sed -i "s/-external-self-/$bigip1ExternalSelfIp/g" bigip1_gcplb_as3.json
sed -i "s/-external-self-/$bigip2ExternalSelfIp/g" bigip2_gcplb_as3.json
#
# old way
function runAS3 () {
    host=$1
    as3File=$2
    echo "starting host: $host file: $as3File"
    count=0
    while [ $count -le 4 ]
        do
            # make task
            task=$(curl -sk -u $CREDS -H "Content-Type: Application/json" -H 'Expect:' -X POST $host$as3Url?async=true -d @$as3File| jq -r .id)
            echo "===== starting as3 task: $task ====="
            sleep 1
            count=$[$count+1]
            # check task code
            taskCount=0
        while [ $taskCount -le 3 ]
        do
            as3CodeType=$(curl -sk -u $CREDS -X GET $host$as3TaskUrl/$task | jq -r type )
            if [[ "$as3CodeType" == "object" ]]; then
                code=$(curl -sk -u $CREDS -X GET $host$as3TaskUrl/$task | jq -r .)
                tenants=$(curl -sk -u $CREDS -X GET $host$as3TaskUrl/$task | jq -r .results[].tenant)
                echo "object: $code"
            elif [ "$as3CodeType" == "array" ]; then  
                echo "array $code check task, breaking"
                break
            else
                echo "unknown type:$as3CodeType"
            fi
            sleep 1
            if jq -e . >/dev/null 2>&1 <<<"$code"; then
                echo "Parsed JSON successfully and got something other than false/null"
                status=$(curl -sk -u $CREDS $host$as3TaskUrl/$task | jq -r .results[].message)
                case $status in
                *progress)
                    # in progress
                    echo -e "Running: $task status: $status tenants: $tenants count: $taskCount "
                    sleep 120
                    taskCount=$[$taskCount+1]
                    ;;
                *Error*)
                    # error
                    echo -e "Error Task: $task status: $status tenants: $tenants "
                    break
                    ;;
                *failed*)
                    # failed
                    echo -e "failed: $task status: $status tenants: $tenants "
                    break
                    ;;
                *success*)
                    # successful!
                    echo -e "success: $task status: $status tenants: $tenants "
                    break 3
                    ;;
                no*change)
                    # finished
                    echo -e "no change: $task status: $status tenants: $tenants "
                    break 4
                    ;;
                *)
                # other
                echo "status: $status"
                debug=$(curl -sk -u $CREDS $host$as3TaskUrl/$task)
                echo "debug: $debug"
                error=$(curl -sk -u $CREDS $host$as3TaskUrl/$task | jq -r '.results[].message')
                echo "Other: $task, $error"
                break
                ;;
                esac
            else
                echo "Failed to parse JSON, or got false/null"
                echo "AS3 status code: $code"
                debug=$(curl -sk -u $CREDS $host$doTaskUrl/$task)
                echo "debug AS3 code: $debug"
                count=$[$count+1]
            fi
        done
    done
}
# run as3 old way
runAS3 "https://$bigip1MgmtIp" "bigip1_gcplb_as3.json"
runAS3 "https://$bigip2MgmtIp" "bigip2_gcplb_as3.json"
#
# f5 cli new way
#f5 cli
#docker run -it -v "$HOME/.f5_cli:/root/.f5_cli" -v "$(pwd):/f5-cli" f5devcentral/f5-cli:latest /bin/bash -c "f5 login --authentication-provider bigip --host $bigip1MgmtIp --user $admin_username --password "$admin_password" && f5 bigip extension service create --component as3 --declaration bigip1_gcplb_as3.json"
#docker run -it -v "$HOME/.f5_cli:/root/.f5_cli" -v "$(pwd):/f5-cli" f5devcentral/f5-cli:latest /bin/bash -c "f5 login --authentication-provider bigip --host $bigip2MgmtIp --user $admin_username --password "$admin_password" && f5 bigip extension service create --component as3 --declaration bigip2_gcplb_as3.json"
#