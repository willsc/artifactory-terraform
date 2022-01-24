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
  access_token = "In0.eyJleHQiOiJ7XCJyZXZvY2FibGVcIjpcInRydWVcIn0iLCJzdWIiOiJqZmFjQDAxZnM0N2pqZ2ZwbTNyMHNwMGdrbjgwcDlwXC91c2Vyc1wvZHVuY2FuY2xlbmNoMEBnbWFpbC5jb20iLCJzY3AiOiJhcHBsaWVkLXBlcm1pc3Npb25zXC9hZG1pbiIsImF1ZCI6IipAKiIsImlzcyI6ImpmZmVAMDAwIiwiZXhwIjoxNjc0NTkwNzAzLCJpYXQiOjE2NDMwNTQ3MDMsImp0aSI6IjI1ZDQ5MDkwLWY0YzEtNGIwZi1iOGNkLWQzYzNmNjgwYmQyOCJ9.Fd4hPX6NZxMZ23hQXHlJOn5vJcFfI83d3bdTHM6AEA9B80DHhqvYrqcUTY3wHLHDfDXZpi4MZHu94oRdKfzMH-qiZcjXIOCRdQXVe_qeGBx6o0joSMsdUFMkhEa56NkqhlaqxfCQoBTeGTbpijwcRoC22JhbPbC6gPrAQjjog7X4Y3L0mZX61EWnrDPc_8yFdUH0BVfLmIO_nCrh430pDUdK9AI2179Gu_we2c5QD8-r42eNCRNdV1fDaq7OAzZUPkCJdQd_guRL3Pl85s4atdKvAhK-Wpomn2DEzWPWV6WBkPRlwo_tweSSY_lqtJPx-KnKRyGu72dWPmseFYMXkg"
  check_license = false
}

provider "project" {
  url = "https://foobarclench.jfrog.io/artifactory"
  access_token = "iJ7XCJyZXZvY2FibGVcIjpcInRydWVcIn0iLCJzdWIiOiJqZmFjQDAxZnM0N2pqZ2ZwbTNyMHNwMGdrbjgwcDlwXC91c2Vyc1wvZHVuY2FuY2xlbmNoMEBnbWFpbC5jb20iLCJzY3AiOiJhcHBsaWVkLXBlcm1pc3Npb25zXC9hZG1pbiIsImF1ZCI6IipAKiIsImlzcyI6ImpmZmVAMDAwIiwiZXhwIjoxNjc0NTkwNzAzLCJpYXQiOjE2NDMwNTQ3MDMsImp0aSI6IjI1ZDQ5MDkwLWY0YzEtNGIwZi1iOGNkLWQzYzNmNjgwYmQyOCJ9.Fd4hPX6NZxMZ23hQXHlJOn5vJcFfI83d3bdTHM6AEA9B80DHhqvYrqcUTY3wHLHDfDXZpi4MZHu94oRdKfzMH-qiZcjXIOCRdQXVe_qeGBx6o0joSMsdUFMkhEa56NkqhlaqxfCQoBTeGTbpijwcRoC22JhbPbC6gPrAQjjog7X4Y3L0mZX61EWnrDPc_8yFdUH0BVfLmIO_nCrh430pDUdK9AI2179Gu_we2c5QD8-r42eNCRNdV1fDaq7OAzZUPkCJdQd_guRL3Pl85s4atdKvAhK-Wpomn2DEzWPWV6WBkPRlwo_tweSSY_lqtJPx-KnKRyGu72dWPmseFYMXkg"
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
  description      = "Infra group"
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


