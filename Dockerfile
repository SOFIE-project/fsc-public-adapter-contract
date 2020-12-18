# Smart contract installed docker image
#
# Use like this:
#
#   docker run --rm -v output-dir:/build/build/ -e ENV=VAL... <name>
#
# Where applicable environmental variables and their defaults are:
#
#  MIGRATE_HOST=127.0.0.1       JSON-RPC host to connect to
#  MIGRATE_PORT=7545            Port of the above host
#  MIGRATE_NETWORK_ID=*         Network ID of target network
#  MIGRATE_FROM=                Account to use for migrate, empty means first
#                               in the host account list
#  MIGRATE_GAS=6721975          Gas reserved for migrations
#
# To get the deployed contract address, mount a directory to /build in
# the host, and then look for the JSON files of the deployed contracts
# in /build/contracts directory. For example, if the deployed contract
# is named `SampleContract`, then you can find the address of the
# deployed contract with:
#
#   cat output-dir/contracts/SampleContract.json | \
#       jq -r '.networks | to_entries | map(.value.address)[0]'
#
# Please do use this method instead of parsing output of truffle
# migrate...

# This is a run-once-during-deployment container, so we do not put
# weight on minimizing the image size. Just use the official node
# image with all of the bells and whistles pre-installed.
FROM node:14
WORKDIR /build
COPY . ./
RUN npm install -g
RUN npx --no-install truffle compile
CMD ["npx", "--no-install", "truffle", "migrate", "--network", "dynamic"]
