
resource "kubernetes_cron_job" "label-manager" {
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
              name  = "github-label-manager"
              image = "xorima/github-label-manager:${var.app_version}"
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
                name  = "GLM_SOURCE_REPO_OWNER"
                value = var.source_repo_owner
              }
              env {
                name  = "GLM_SOURCE_REPO_NAME"
                value = var.source_repo_name
              }

              env {
                name  = "GLM_SOURCE_REPO_PATH"
                value = var.source_repo_path
              }

              env {
                name  = "GLM_DESTINATION_REPO_OWNER"
                value = var.destination_repo_owner
              }

              env {
                name  = "GLM_DESTINATION_REPO_TOPICS"
                value = var.destination_repo_topics
              }

              env {
                name  = "GLM_DELETE_MODE"
                value = var.delete_mode
              }
            }
            restart_policy = "Never"
          }
        }
      }
    }
  }
}
