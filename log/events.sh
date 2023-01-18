#!/bin/bash -xv
  


dir_name="kubectl-event-logs"



linkname="eventlogs"
current_time=$(date "+%Y.%m.%d-%H.%M.%S")



filename=$linkname.$current_time.log




#directory=/var/log/my/directory
if [ ! -d "$dir_name" ]; then
mkdir -p "$dir_name"
fi
cd $dir_name
if [[ ! -e $filename ]] || [[ ! -e $linkname ]]; then
    touch "$filename"
    #echo "Just a test" >> "$filename"
    kubefile=/kubeconfig/k3s.yaml
    export KUBECONFIG=$kubefile
    kubectl get events -A &> "$filename"
fi



cd $dir_name


# Get the current time

CUR_TIME=$(date +%H:%M)


# Check if it is currently 12:00 AM (UTC: 18:30)

if [ $CUR_TIME == "18:30" ]; then

  # Tar the log files

  tar -czf logs.tar.gz *.log

fi

exit 0

