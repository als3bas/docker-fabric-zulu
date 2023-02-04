
MINECRAFT_VERSION=$1

if [ -z "${MINECRAFT_VERSION}" ]; then
    echo "Usage: $0 <minecraft version>"
    exit 1
fi

if [ ! -f "fabric.jar" ]; then
    echo "Installing fabric jar"
else
    echo "Cleaning old fabric jar"
    rm fabric.jar
fi

LATEST_FABRIC_LOADER=$(curl -s https://meta.fabricmc.net/v2/versions/loader | jq -r '.[0].version')
LATEST_INSTALLER=$(curl -s https://meta.fabricmc.net/v2/versions/installer | jq -r '.[0].version')
FABRIC_DOWNLOAD_URL="https://meta.fabricmc.net/v2/versions/loader/${MINECRAFT_VERSION}/${LATEST_FABRIC_LOADER}/${LATEST_INSTALLER}/server/jar"

echo "------------------------------"
echo "Minecraft Version: ${MINECRAFT_VERSION}"
echo "Latest Fabric Loader Version: ${LATEST_FABRIC_LOADER}"
echo "Latest Fabric Installer Version: ${LATEST_INSTALLER}"
echo "Downloading from ${FABRIC_DOWNLOAD_URL}"
echo "------------------------------"


curl -s -o fabric.jar ${FABRIC_DOWNLOAD_URL}
