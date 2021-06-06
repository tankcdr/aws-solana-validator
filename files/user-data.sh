#!/usr/bin/bash

# https://github.com/solana-labs/solana/releases
VERSION=1.6.9
SOLANA_HOME=/opt/sol
SOLANA_USER=sol
RUN_SCRIPT=${SOLANA_HOME}/validator.sh
SERVICE=/etc/systemd/system/sol.service

# install Solana
cd "$(mktemp -d)" || exit
wget https://github.com/solana-labs/solana/releases/download/v${VERSION}/solana-release-x86_64-unknown-linux-gnu.tar.bz2
tar jxf solana-release-x86_64-unknown-linux-gnu.tar.bz2
mv solana-release /usr/share/

# setup new user
sudo mkdir "${SOLANA_HOME}"
sudo adduser --disabled-password --gecos "" --home "${SOLANA_HOME}" "${SOLANA_USER}"

# create run script
sudo cat > ${RUN_SCRIPT} <<EOL
#!/usr/bin/bash
solana-validator \
    --ledger ${SOLANA_HOME}/ledger \
    --log ${SOLANA_HOME}/solana-validator.log \
    --identity ${SOLANA_HOME}/validator-keypair.json \
    --no-voting \
    --trusted-validator 7Np41oeYqPefeNQEHSv1UDhYrehxin3NStELsSKCT4K2 \
    --trusted-validator GdnSyH3YtwcxFvQrVVJMm1JhTS4QVX7MFsX56uJLUfiZ \
    --trusted-validator DE1bawNcRJB9rVm3buyMVfr8mBEoyyu73NBovf2oXJsJ \
    --trusted-validator CakcnaRDHka2gXyfbEd2d3xsvkJkqsLw2akB3zsN1D2S \
    --no-untrusted-rpc \
    --rpc-port 8899 \
    --private-rpc \
    --dynamic-port-range 8000-8010 \
    --entrypoint entrypoint.mainnet-beta.solana.com:8001 \
    --entrypoint entrypoint2.mainnet-beta.solana.com:8001 \
    --entrypoint entrypoint3.mainnet-beta.solana.com:8001 \
    --entrypoint entrypoint4.mainnet-beta.solana.com:8001 \
    --entrypoint entrypoint5.mainnet-beta.solana.com:8001 \
    --expected-genesis-hash 5eykt4UsFv8P8NJdTREpY1vzqKqZKvdpKuc147dw2N9d \
    --wal-recovery-mode skip_any_corrupted_record \
    --limit-ledger-size \
    --enable-rpc-transaction-history
EOL

# make executable
chmod +x ${RUN_SCRIPT}

# create systemd
sudo cat > ${SERVICE} <<EOL
[Unit]
Description=Solana Validator
After=network.target
Wants=solana-sys-tuner.service
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=1
User=${SOLANA_USER}
LimitNOFILE=700000
LogRateLimitIntervalSec=0
Environment="PATH=/bin:/usr/bin:/usr/share/solana-release/bin"
ExecStart=${RUN_SCRIPT}

[Install]
WantedBy=multi-user.target
EOL

PATH="/usr/share/solana-release/bin:$PATH"
solana-keygen new -o ${SOLANA_HOME}/validator-keypair.json
solana-sys-tuner --user ${SOLANA_USER}> ${SOLANA_HOME}/sys-tuner.log 2>&1 &

sudo chown -R ${SOLANA_USER}:${SOLANA_USER} ${SOLANA_HOME}
sudo systemctl enable --now sol
