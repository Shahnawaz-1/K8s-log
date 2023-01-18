FROM ubuntu
  

COPY ./events.sh /events.sh
RUN chmod +x /events.sh
RUN apt update

RUN apt install -y vim

RUN apt install curl -y
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
RUN curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
RUN echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
RUN install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

RUN chmod +x kubectl

RUN mkdir -p ~/.local/bin

RUN mv ./kubectl ~/.local/bin/kubectl

ENTRYPOINT ["./events.sh"]
#ENTRYPOINT ["tail", "-f", "/dev/null"]
