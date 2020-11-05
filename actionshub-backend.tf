resource "kubernetes_namespace" "actionshub-backend" {
  metadata {
    labels = {
      purpose = "actionshub"
    }
    name = "actionshub-backend"
  }
}

resource "kubernetes_secret" "xorimabot-github-sous-chef-backend" {
  metadata {
    name      = "xorimabot-github"
    namespace = kubernetes_namespace.actionshub-backend.metadata[0].name
  }

  data = {
    github_token    = var.github_user_token
    github_git_name = var.github_user_config.name
    github_email    = var.github_user_config.email
    github_username = var.github_user_config.username
  }
}


module "actionshub-label-manager" {
  source                   = "./modules/github_label_manager"
  kube_config              = local.kube_config
  namespace                = kubernetes_namespace.actionshub-backend.metadata[0].name
  resource_name            = "github-label-manager"
  cronjob_schedule         = "0 16 * * *"
  app_version              = local.app_version.github_label_manager
  github_token_secret_name = kubernetes_secret.xorimabot-github-sous-chef-backend.metadata[0].name
  source_repo_owner        = "actionshub"
  source_repo_path         = "labels/cookbook"
  destination_repo_owner   = "actionshub"
  destination_repo_topics  = "action,github-action"
}

module "actionshub-file-manager-action" {
  source                   = "./modules/github_file_manager"
  kube_config              = local.kube_config
  namespace                = kubernetes_namespace.actionshub-backend.metadata[0].name
  resource_name            = "github-file-manager-ide"
  cronjob_schedule         = "0 12 * * *"
  app_version              = local.app_version.github_file_manager
  github_token_secret_name = kubernetes_secret.xorimabot-github-sous-chef-backend.metadata[0].name
  source_repo_owner        = "actionshub"
  source_repo_path         = "standardfiles/action"
  destination_repo_owner   = "actionshub"
  destination_repo_topics  = "action,github-action"
}
