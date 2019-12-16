# Pick a Docker version: test or get (i.e., stable).
DOCKER_VERSION="test" # or "get" if you're scared

# Download and run the Docker installer script.
curl -fsSL https://$DOCKER_VERSION.docker.com | sh -

# Pick a version of docker-compose from the releases.
DOCKER_COMPOSE_VERSION="1.25.0-rc2" # or "1.24.1" if you're scared

# Download docker-compose.
sudo curl -fsSL "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Make docker-compose executable.
sudo chmod +x /usr/local/bin/docker-compose

# Add the user to the docker group.
sudo adduser $(whoami) docker

# Set primary group to docker. (Or log out and back in.)
newgrp docker

# Test some docker commands.
docker ps
docker run hello-world