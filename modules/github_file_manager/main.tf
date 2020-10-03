
resource "kubernetes_cron_job" "file-manager" {
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
              name  = "github-file-manager"
              image = "xorima/github-file-manager:${var.app_version}"
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
                name  = "GFM_SOURCE_REPO_OWNER"
                value = var.source_repo_owner
              }
              env {
                name  = "GFM_SOURCE_REPO_NAME"
                value = var.source_repo_name
              }

              env {
                name  = "GFM_SOURCE_REPO_PATH"
                value = var.source_repo_path
              }

              env {
                name  = "GFM_DESTINATION_REPO_OWNER"
                value = var.destination_repo_owner
              }

              env {
                name  = "GFM_DESTINATION_REPO_TOPICS"
                value = var.destination_repo_topics
              }

              env {
                name  = "GFM_BRANCH_NAME"
                value = var.branch_name
              }

              env {
                name  = "GFM_PULL_REQUEST_TITLE"
                value = var.pr_title
              }

              env {
                name  = "GFM_PULL_REQUEST_BODY"
                value = local.pr_body
              }
              env {
                name = "GFM_GIT_NAME"
                value_from {
                  secret_key_ref {
                    name = var.github_token_secret_name
                    key  = "github_git_name"
                  }
                }
              }

              env {
                name = "GFM_GIT_EMAIL"
                value_from {
                  secret_key_ref {
                    name = var.github_token_secret_name
                    key  = "github_email"
                  }
                }
              }

              env {
                name = "GFM_GIT_USERNAME"
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
