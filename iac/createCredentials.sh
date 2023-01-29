# Create Akamai credentials file.
if [ ! -z "$ENVIRONMENT_ATTRIBUTES" ]; then
  echo "$ENVIRONMENT_ATTRIBUTES" > $HOME/.environment.tfvars
fi

echo "[default]" > .edgerc
echo "host = $(cat $HOME/.environment.tfvars | grep apiHostname |  awk '{print $3}' | tr -d \")" >> .edgerc
echo "access_token = $(cat $HOME/.environment.tfvars | grep accessToken |  awk '{print $3}' | tr -d \")" >> .edgerc
echo "client_token = $(cat $HOME/.environment.tfvars | grep clientToken |  awk '{print $3}' | tr -d \")" >> .edgerc
echo "client_secret = $(cat $HOME/.environment.tfvars | grep clientSecret |  awk '{print $3}' | tr -d \")" >> .edgerc
echo "account_key = $(cat $HOME/.environment.tfvars | grep account |  awk '{print $3}' | tr -d \")" >> .edgerc
