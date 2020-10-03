resource "kubernetes_namespace" "sous-chefs-backend" {
  metadata {
    labels = {
      purpose = "sous-chefs"
    }
    name = "sous-chefs-backend"
  }
}

resource "kubernetes_secret" "xorimabot-github-sous-chef-backend" {
  metadata {
    name      = "xorimabot-github"
    namespace = kubernetes_namespace.sous-chefs-backend.metadata[0].name
  }

  data = {
    github_token    = var.github_xorimabot_token
    github_git_name = var.github_xorimabot_name
    github_email    = var.github_xorimabot_email
    github_username = var.github_xorimabot_username
  }
}


module "sous-chefs-label-manager" {
  source                   = "./modules/github_label_manager"
  kube_config              = local.kube_config
  namespace                = kubernetes_namespace.sous-chefs-backend.metadata[0].name
  resource_name            = "github-label-manager"
  cronjob_schedule         = "0 16 * * *"
  app_version              = local.app_version.github_label_manager
  github_token_secret_name = kubernetes_secret.xorimabot-github-sous-chef-backend.metadata[0].name
  source_repo_owner        = "sous-chefs"
  source_repo_path         = "labels/cookbook"
  destination_repo_owner   = "sous-chefs"
  destination_repo_topics  = "chef-cookbook"
}

module "sous-chefs-file-manager-ide" {
  source                   = "./modules/github_file_manager"
  kube_config              = local.kube_config
  namespace                = kubernetes_namespace.sous-chefs-backend.metadata[0].name
  resource_name            = "github-file-manager-ide"
  cronjob_schedule         = "0 14 * * *"
  app_version              = local.app_version.github_file_manager
  github_token_secret_name = kubernetes_secret.xorimabot-github-sous-chef-backend.metadata[0].name
  source_repo_owner        = "sous-chefs"
  source_repo_path         = "standardfiles/ide"
  destination_repo_owner   = "sous-chefs"
  destination_repo_topics  = "ide"
}

module "sous-chefs-file-manager-terraform" {
  source                   = "./modules/github_file_manager"
  kube_config              = local.kube_config
  namespace                = kubernetes_namespace.sous-chefs-backend.metadata[0].name
  resource_name            = "github-file-manager-terraform"
  cronjob_schedule         = "0 12 * * *"
  app_version              = local.app_version.github_file_manager
  github_token_secret_name = kubernetes_secret.xorimabot-github-sous-chef-backend.metadata[0].name
  source_repo_owner        = "sous-chefs"
  source_repo_path         = "standardfiles/terraform"
  destination_repo_owner   = "sous-chefs"
  destination_repo_topics  = "terraform"
}

module "sous-chefs-file-manager-cookbook" {
  source                   = "./modules/github_file_manager"
  kube_config              = local.kube_config
  namespace                = kubernetes_namespace.sous-chefs-backend.metadata[0].name
  resource_name            = "github-file-manager-cookbook"
  cronjob_schedule         = "0 13 * * *"
  app_version              = local.app_version.github_file_manager
  github_token_secret_name = kubernetes_secret.xorimabot-github-sous-chef-backend.metadata[0].name
  source_repo_owner        = "sous-chefs"
  source_repo_path         = "standardfiles/cookbook"
  destination_repo_owner   = "sous-chefs"
  destination_repo_topics  = "chef-cookbook"
}

module "sous-chefs-cookstyle-runner" {
  source                   = "./modules/github_cookstyle_runner"
  kube_config              = local.kube_config
  namespace                = kubernetes_namespace.sous-chefs-backend.metadata[0].name
  resource_name            = "github-cookstyle-runner"
  cronjob_schedule         = "0 0 * * *"
  app_version              = local.app_version.github_cookstyle_runner
  github_token_secret_name = kubernetes_secret.xorimabot-github-sous-chef-backend.metadata[0].name
  destination_repo_owner   = "sous-chefs"
  destination_repo_topics  = "chef-cookbook"
  manage_changelog         = true
}
