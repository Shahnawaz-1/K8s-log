Increasing the no of logs that can be retained from kubectl get events. Create a k8s cornjob to capture the events in a log file and keep  rotate the log file after every hour.
 
Pre-requistes.
Config Map
Script.
3.  Docker image.
4.  Cronjob.
 
 
Create config map
  #kubectl create cm log-config --from-file=<your kubeconfig path>
Ex. 
 #kubectl create cm log-config --from-file=/home/core/shan/kubeconfig/
 
 
 
2. Creating a script for taking logs at the end of the day into a directory and pushing it that into a tar file.
    
  a. Create events.sh file


1#!/bin/bash -xv
2  
3
4dir_name="kubectl-event-logs"
5
6
7linkname="eventlogs"
8current_time=$(date "+%Y.%m.%d-%H.%M.%S")
9
10filename=$linkname.$current_time.log
11
12#directory=/var/log/my/directory
13if [ ! -d "$dir_name" ]; then
14mkdir -p "$dir_name"
15fi
16cd $dir_name
17if [[ ! -e $filename ]] || [[ ! -e $linkname ]]; then
18    touch "$filename"
19    #echo "Just a test" >> "$filename"
20    kubefile=/kubeconfig/k3s.yaml
21    export KUBECONFIG=$kubefile
22    kubectl get events -A &> "$filename"
23fi
24
25cd $dir_name
26
27# Get the current time
28CUR_TIME=$(date +%H:%M)
29
30# Check if it is currently 12:05 AM (UTC: 18:35)
31if [ $CUR_TIME == "18:35" ]; then
32# Tar the log files
33tar -czf logs.tar.gz *.log
34fi
35exit 0                              
 
 
 
2. Create a Docker Image.
#vim Dockerfile


1FROM ubuntu
2  
3
4COPY ./events.sh /events.sh
5RUN chmod +x /events.sh
6RUN apt update
7
8RUN apt install -y vim
9
10RUN apt install curl -y
11RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
12RUN curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
13RUN echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
14RUN install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
15
16RUN chmod +x kubectl
17
18RUN mkdir -p ~/.local/bin
19
20RUN mv ./kubectl ~/.local/bin/kubectl
21
22ENTRYPOINT ["./events.sh"]
23#ENTRYPOINT ["tail", "-f", "/dev/null"]
 
a. To build the docker image.
#docker build -t <image name>  .
 
b. Tagging the image.
#docker tag <your image name>  <your docker registry name/your image name>
 
c. Push the image.
#docker push  <your docker registry name/your image name
 
 
3.  A cron job for scheduling for every hour and to capture the log in a directory.
    a.  Create cronjob.yaml


1apiVersion: batch/v1
2kind: CronJob
3metadata:
4  name: shan
5spec:
6  schedule: "0 * * * *"
7  jobTemplate:
8    spec:
9      template:
10        spec:
11          containers:
12          - name: log-container
13            image: <your docker registry name/your image name>
14            imagePullPolicy: IfNotPresent
15            volumeMounts:
16            - name: config-volume
17              mountPath: /kubeconfig
18            - name: volume
19              mountPath: /kubectl-event-logs
20          volumes:
21          - name: volume
22            hostPath:
23              path: /home/core/shan/kubectl-event-logs
24              type: DirectoryOrCreate
25          - name: config-volume
26            configMap:
27              name: log-config2
28          restartPolicy: OnFailure
 
b. Apply the cronjob.yaml
#kubectl apply -f cronjob.yaml
c. check the cronjob created.
#kubectl get cj
d. Check the pod's created.
#kubectl get pods

