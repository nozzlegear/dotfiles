function DockerImageExists ($imageName) {
	$exists = $(docker images | grep "$imageName");

	return !!$exists
}

function DockerContainerExists ($containerName) {
	$exists = $(docker ps -a | grep "$containerName")

	return !!$exists
}

if (which docker 2> $null) {
	$couchImage = "klaemo/couchdb"
	$couchContainer = "couchy"
	$pgImage = "postgres"
	$pgContainer = "posty"
	
	# Pull in Docker packages if they don't exist
	if (DockerImageExists "$couchImage") {
		echo "Docker image \"$couchImage\" already exists."
	} else {
		docker pull $couchImage
	}

	if (DockerImageExists "$pgImage") {
		echo "Docker image \"$pgImage\" already exists."
	} else {
		docker pull $pgImage
	}

	# Create containers
	if ($(DockerImageExists "$couchImage") -and -not $(DockerContainerExists "$couchContainer")) {
		docker run --name "$couchContainer" --restart unless-stopped -d -p 5984:5984 "$couchImage"
	}

	if ($(DockerImageExists "$pgImage") -and -not $(DockerContainerExists "$pgContainer")) {
		docker run --name "$pgContainer" --restart unless-stopped -d -p 0.0.0.0:5432:5432 -e POSTGRES_PASSWORD=dev_password -e POSTGRES_USER=pg "$pgImage"
	}
} else {
	Write-Error "Could not find Docker command. Most likely it hasn't started yet."
}

