FROM python:3.8

RUN DEBIAN_FRONTEND=noninteractive apt update; \
    DEBIAN_FRONTEND="noninteractive" apt-get install -y -o DPkg::Options::="--force-confnew" --no-install-recommends --no-upgrade \
        apt-transport-https \
        ca-certificates \
        curl \
        jq \
        software-properties-common \
        zip \
        awscli \
        unzip; \
        apt-get autoremove -y; \
        rm -rf /var/lib/apt/lists/*;

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"; \
    unzip awscliv2.zip; \
    rm awscliv2.zip; \
    ./aws/install;

COPY entrypoint.sh /opt/entrypoint.sh
RUN chmod +x /opt/entrypoint.sh
ENTRYPOINT ["/opt/entrypoint.sh"]
