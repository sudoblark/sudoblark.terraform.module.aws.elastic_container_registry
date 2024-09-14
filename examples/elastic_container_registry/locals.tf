locals {
  raw_ecr_registries = [
    {
      suffix : "repo-one"
      lifecycle_rules : [
        {
          rulePriority : 1
          description : "Ensure only 10 pre-release images are kept in the registry."
          tagStatus : "tagged"
          tagPatternList : [
            "*-prerelease-*"
          ]
          countType : "imageCountMoreThan"
          countNumber : 10
          action : "expire"
        }
      ]
    }
  ]
}