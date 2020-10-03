resource "kubernetes_namespace" "chef-cookbooks-backend" {
  metadata {
    labels = {
      purpose = "chef-cookbooks"
    }
    name = "chef-cookbooks-backend"
  }
}

resource "kubernetes_secret" "xorimabot-github-chef-cookbooks-backend" {
  metadata {
    name      = "xorimabot-github"
    namespace = kubernetes_namespace.chef-cookbooks-backend.metadata[0].name
  }

  data = {
    github_token    = var.github_xorimabot_token
    github_git_name = var.github_xorimabot_name
    github_email    = var.github_xorimabot_email
    github_username = var.github_xorimabot_username
  }
}

module "chef-cookbooks-file-manager-cookbook" {
  source                   = "./modules/github_file_manager"
  kube_config              = local.kube_config
  namespace                = kubernetes_namespace.chef-cookbooks-backend.metadata[0].name
  resource_name            = "github-file-manager-cookbook"
  cronjob_schedule         = "0 11 * * *"
  app_version              = local.app_version.github_file_manager
  github_token_secret_name = kubernetes_secret.xorimabot-github-chef-cookbooks-backend.metadata[0].name
  source_repo_owner        = "chef-cookbooks"
  source_repo_path         = "standardfiles/cookbook"
  destination_repo_owner   = "chef-cookbooks"
  destination_repo_topics  = "cookbook"
}

module "chef-cookbooks-cookstyle-runner" {
  source                   = "./modules/github_cookstyle_runner"
  kube_config              = local.kube_config
  namespace                = kubernetes_namespace.chef-cookbooks-backend.metadata[0].name
  resource_name            = "github-cookstyle-runner"
  cronjob_schedule         = "0 17 * * *"
  app_version              = local.app_version.github_cookstyle_runner
  github_token_secret_name = kubernetes_secret.xorimabot-github-chef-cookbooks-backend.metadata[0].name
  destination_repo_owner   = "chef-cookbooks"
  destination_repo_topics  = "cookbook"
  manage_changelog         = true
}
