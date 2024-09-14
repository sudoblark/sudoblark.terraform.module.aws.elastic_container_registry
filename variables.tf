# Input variable definitions
variable "environment" {
  description = "Which environment this is being instantiated in."
  type        = string
  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Must be either dev, test or prod"
  }
}

variable "application_name" {
  description = "Name of the application utilising resource."
  type        = string
}

variable "raw_ecr_registries" {
  description = <<EOF

Data structure
---------------
A list of dictionaries, where each dictionary has the following attributes:

REQUIRED
---------
- suffix                      : Suffix to be added to registry name

OPTIONAL
---------
- lifecycle_rules              : A list of dictionaries, where each dictionary is a rule with the following
attributes:

Note: See which map on to https://docs.aws.amazon.com/AmazonECR/latest/userguide/LifecyclePolicies.html#lifecycle_policy_parameters
for more information on what is and isn't permissible

-- rulePriority               : int priority, lowest wins, must be a positive integer.
-- description                : OPTIONAL description of the policy, defaults to null
-- tagStatus                  : OPTIONAL, determines whether the lifecycle policy rule that you are adding specifies a tag for an image
                                Defaults to any
-- tagPatternList             : OPTIONAL, specify tag patterns to expire rather than wildcarding.
-- tagPrefixList              : OPTIONAL, specify tag patterns to expire, rather than wildcarding.
-- countType                  : Specify a count type to apply to the images.
-- countUnit                  : Specify a count unit of days to indicate that as the unit of time, in addition to countNumber, which is the number of days.
-- countNumber                : Specify a count number. Acceptable values are positive integers (0 is not an accepted value).
-- action                     : Only permissible value is expire

EOF
  type = list(
    object({
      suffix = string,
      lifecycle_rules = optional(list(
        object({
          rulePriority : number,
          description : optional(string, null),
          tagStatus = optional(string, "any"),
          tagPatternList : optional(list(string), null),
          tagPrefixList : optional(list(string), null),
          countType : string,
          countUnit : optional(string, null),
          countNumber : number,
          action : string
        })
      ), []),
    })
  )

  validation {
    condition = alltrue([
      for registry in var.raw_ecr_registries : alltrue([
        for rule in registry.lifecycle_rules : alltrue([
          rule.rulePriority > 0
        ])
      ])
    ])
    error_message = "rulePriority must be a positive integer."
  }

  validation {
    condition = alltrue([
      for registry in var.raw_ecr_registries : alltrue([
        for rule in registry.lifecycle_rules : alltrue([
          contains(["tagged", "untagged", "any"], rule.tagStatus)
        ])
      ])
    ])
    error_message = "tagStatus must be one of: 'tagged', 'untagged', 'any'."
  }

  validation {
    condition = alltrue([
      for registry in var.raw_ecr_registries : alltrue([
        for rule in registry.lifecycle_rules : alltrue([
          /*
            Negate condition, such that we fail _if_ tagStatus is tagged and both
            tagPatternList and taxPrefixList are null. Otherwise, we would only pass
            if this is true which is the opposite of what we want.
          */
          !(
            rule.tagStatus == "tagged" &&
            rule.tagPatternList == null &&
            rule.tagPrefixList == null
          )
        ])
      ])
    ])
    error_message = "If tagStatus is 'tagged', rule must define either tagPatternList or tagPrefix List"
  }

  validation {
    condition = alltrue([
      for registry in var.raw_ecr_registries : alltrue([
        for rule in registry.lifecycle_rules : alltrue([
          contains(["imageCountMoreThan", "sinceImagePushed"], rule.countType)
        ])
      ])
    ])
    error_message = "countType must be one of: 'imageCountMoreThan', 'sinceImagePushed'."
  }

  validation {
    condition = alltrue([
      for registry in var.raw_ecr_registries : alltrue([
        for rule in registry.lifecycle_rules : alltrue([
          // i.e. only validate countUnit if a value is actually provided
          rule.countUnit == null ? true : contains(["days"], rule.countUnit)
        ])
      ])
    ])
    error_message = "countUnit must be one of: 'days'."
  }

  validation {
    condition = alltrue([
      for registry in var.raw_ecr_registries : alltrue([
        for rule in registry.lifecycle_rules : alltrue([
          rule.countType == "sinceImagePushed" ? rule.countUnit != null : true
        ])
      ])
    ])
    error_message = "countUnit must be set if countType is 'sinceImagePushed'"
  }

  validation {
    condition = alltrue([
      for registry in var.raw_ecr_registries : alltrue([
        for rule in registry.lifecycle_rules : alltrue([
          contains(["expire"], rule.action)
        ])
      ])
    ])
    error_message = "action must be one of: 'expire'."
  }
}