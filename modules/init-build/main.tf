# Not currently being used

resource "null_resource" "build" {
  provisioner "local-exec" {
    command = "make build"
    working_dir = "${path.root}/./application"
    environment = {
        TAG = "latest"
        REGISTRY_ID = "880763692340"
        REPOSITORY_REGION = "eu-west-1"
        APP_NAME = "simpleapp"
        ENV_NAME = "dev"
    }
  }
}