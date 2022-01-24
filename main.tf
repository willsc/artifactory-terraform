terraform {
  required_providers {
    artifactory = {
      source  = "registry.terraform.io/jfrog/artifactory"
      version = "2.6.24"
    }
    project = {
       source = "registry.terraform.io/jfrog/project"
       version = "1.0.1"

    }
  }
}



# Configure the Artifactory provider
provider "artifactory" {
  url = "https://foobarclench.jfrog.io/artifactory"
  access_token = ""
  check_license = false
}

provider "project" {
  url = "https://foobarclench.jfrog.io/artifactory"
  access_token = ""
  check_license = false
}

# Create a new repository
resource "artifactory_local_repository" "pypi-libs" {

  key             = "pypi-libs-foobar"
  package_type    = "pypi"
  repo_layout_ref = "simple-default"
  description     = "A pypi repository for python packages"
  xray_index       = true
  property_sets     = ["artifactory"]

}

resource "artifactory_group" "dev-group" {
  name             = "Developers"
  description      = "Dev group"
  admin_privileges = false
}

resource "artifactory_group" "infra-group" {
  name             = "Infrastructure"
  description      = "Infrs group"
  admin_privileges = false
}


resource "artifactory_local_repository" "docker-local" {
  key          = "docker-local"
  package_type = "docker"
  xray_index   = true
  description  = "docker-local"
}


resource "project" "infra-project" {
  key = "myproj"
  display_name = "InfraProject"
  description  = "Infra Project"
  admin_privileges {
    manage_members   = true
    manage_resources = true
    index_resources  = true
  }
  max_storage_in_gibibytes   = 10
  block_deployments_on_limit = false
  email_notification         = true

  member {
    name  = "user1"
    roles = ["Developer", "Project Admin"]
  }

  member {
    name  = "user2"
    roles = ["Developer"]
  }

  group {
    name  = "qa"
    roles = ["qa"]
  }

  group {
    name  = "release"
    roles = ["Release Manager"]
  }

  role {
    name         = "dev"
    description  = "dev role"
    type         = "CUSTOM"
    environments = ["DEV"]
    actions      = var.dev_roles
  }

  role {
    name         = "devop"
    description  = "DevOp role"
    type         = "CUSTOM"
    environments = ["DEV", "PROD"]
    actions      = var.devop_roles
  }

  repos = ["docker-local"]

  depends_on = [

    artifactory_group.dev-group,
    artifactory_local_repository.docker-local,

  ]
}


