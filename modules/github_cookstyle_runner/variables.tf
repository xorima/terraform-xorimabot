variable "kube_config" {
  type = object({
    host                   = string
    token                  = string
    cluster_ca_certificate = string
  })
}

variable "namespace" {
  description = "Which namespace to deploy into, must be pre-created"
}

variable "resource_name" {
  description = "The name of the resource to create"
}

variable "cronjob_schedule" {
  description = "When to run, in cron format"
}

variable "app_version" {
  description = "The version of label manager to run"
}

variable "github_token_secret_name" {
  description = "The name of the secret which contains the github_token"
}

variable "destination_repo_topics" {
  description = "Topics to use to find the repos to match against"
}

variable "destination_repo_owner" {
  description = "The name of the owner for the repos we wish to find"
}

variable "branch_name" {
  description = "The name of the branch to create changes on"
  default     = "automated/cookstyle"
}

variable "pr_title" {
  description = "The title of the pr to raise"
  default     = "Automated PR: Cookstyle Changes"
}

variable "changelog_location" {
  description = "The location of the changelog"
  default     = "CHANGELOG.md"
}

variable "changelog_marker" {
  description = "The marker in the changelog as to where to update from"
  default     = "## Unreleased"
}

variable "manage_changelog" {
  description = "Should we manage the changelog?"
  default     = false
}

locals {
  manage_changelog = var.manage_changelog == true ? "1" : "0"
}