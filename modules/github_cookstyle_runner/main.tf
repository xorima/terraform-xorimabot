
resource "kubernetes_cron_job" "cookstyle-runner" {
  metadata {
    name      = var.resource_name
    namespace = var.namespace
  }
  spec {
    concurrency_policy        = "Replace"
    failed_jobs_history_limit = 3
    schedule                  = var.cronjob_schedule
    job_template {
      metadata {}
      spec {
        backoff_limit              = 2
        ttl_seconds_after_finished = 10
        template {
          metadata {}
          spec {
            container {
              name  = "github-cookstyle-runner"
              image = "xorima/github-cookstyle-runner:${var.app_version}"
              env {
                name = "GITHUB_TOKEN"
                value_from {
                  secret_key_ref {
                    name = var.github_token_secret_name
                    key  = "github_token"
                  }
                }
              }
              env {
                name  = "GCR_DESTINATION_REPO_OWNER"
                value = var.destination_repo_owner
              }

              env {
                name  = "GCR_DESTINATION_REPO_TOPICS"
                value = var.destination_repo_topics
              }

              env {
                name  = "GCR_BRANCH_NAME"
                value = var.branch_name
              }

              env {
                name  = "GCR_PULL_REQUEST_TITLE"
                value = var.pr_title
              }

              env {
                name  = "GCR_CHANGELOG_LOCATION"
                value = var.changelog_location
              }

              env {
                name  = "GCR_CHANGELOG_MARKER"
                value = var.changelog_marker
              }

              env {
                name  = "GCR_MANAGE_CHANGELOG"
                value = local.manage_changelog
              }

              env {
                name = "GCR_GIT_NAME"
                value_from {
                  secret_key_ref {
                    name = var.github_token_secret_name
                    key  = "github_git_name"
                  }
                }
              }

              env {
                name = "GCR_GIT_EMAIL"
                value_from {
                  secret_key_ref {
                    name = var.github_token_secret_name
                    key  = "github_email"
                  }
                }
              }

              env {
                name = "GCM_GIT_USERNAME"
                value_from {
                  secret_key_ref {
                    name = var.github_token_secret_name
                    key  = "github_username"
                  }
                }
              }
            }
            restart_policy = "Never"
          }
        }
      }
    }
  }
}
