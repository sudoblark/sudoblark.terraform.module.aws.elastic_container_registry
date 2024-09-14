locals {
  lifecycle_rules = {
    for repository in var.raw_ecr_registries :
    repository.suffix => [
      /*
        Use of merge statements ensures only non-null values are added to the dictionary. i.e.
        if the value is null, do not append. This is required as jsonencode does not ignore null values,
        thus these cause terraform apply to fail as null is not valid for lifecycle policy. Furthermore,
        looking at https://docs.aws.amazon.com/AmazonECR/latest/userguide/LifecyclePolicies.html#lifecycle_policy_parameters
        there are no sensible defaults we may otherwise provide.
      */
      for rule in repository.lifecycle_rules : merge({
        rulePriority = rule.rulePriority
        selection = merge({
          tagStatus   = rule.tagStatus
          countType   = rule.countType,
          countNumber = rule.countNumber
          },
          rule.tagPatternList != null ? { tagPatternList = rule.tagPatternList } : {},
          rule.tagPrefixList != null ? { tagPrefixList = rule.tagPrefixList } : {},
          rule.countUnit != null ? { countUnit = rule.countUnit } : {}
        )
        action = {
          type = rule.action
        }
        },
      rule.description != null ? { description = rule.description } : {})
    ]
  }
  actual_ecr_registries = flatten([
    for repository in var.raw_ecr_registries : {
      suffix : repository.suffix,
      repository_policy : data.aws_iam_policy_document.registry_policy.json
      repository_lifecycle_policy : repository.lifecycle_rules != [] ? jsonencode({ rules = local.lifecycle_rules[repository.suffix] }) : null
    }
  ])
}

module "ecr" {
  for_each = { for registry in local.actual_ecr_registries : registry.suffix => registry }


  source  = "terraform-aws-modules/ecr/aws"
  version = "~> 2.2"

  create_repository = true
  repository_name   = lower("${var.environment}-${var.application_name}-${each.value["suffix"]}")

  create_repository_policy    = false
  repository_policy           = each.value["repository_policy"]
  repository_lifecycle_policy = each.value["repository_lifecycle_policy"]

  repository_image_tag_mutability = "IMMUTABLE"
  repository_image_scan_on_push   = true
  repository_force_delete         = false
}