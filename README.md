# sudoblark.terraform.module.aws.elastic_container_registry
Terraform module to create N number of Elastic Container Registries with custom lifecycle rules. - repo managed by sudoblark.terraform.github

## Developer documentation
The below documentation is intended to assist a developer with interacting with the Terraform module in order to add,
remove or update functionality.

### Pre-requisites
* terraform_docs

```sh
brew install terraform_docs
```

* tfenv
```sh
git clone https://github.com/tfutils/tfenv.git ~/.tfenv
echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bash_profile
```

* Virtual environment with pre-commit installed

```sh
python3 -m venv venv
source venv/bin/activate
pip install pre-commit
```
### Pre-commit hooks
This repository utilises pre-commit in order to ensure a base level of quality on every commit. The hooks
may be installed as follows:

```sh
source venv/bin/activate
pip install pre-commit
pre-commit install
pre-commit run --all-files
```

# Module documentation
The below documentation is intended to assist users in utilising the module, the main thing to note is the
[data structure](#data-structure) section which outlines the interface by which users are expected to interact with
the module itself, and the [examples](#examples) section which has examples of how to utilise the module.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.63.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.67.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecr"></a> [ecr](#module\_ecr) | terraform-aws-modules/ecr/aws | ~> 2.2 |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current_account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.registry_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current_region](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | Name of the application utilising resource. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Which environment this is being instantiated in. | `string` | n/a | yes |
| <a name="input_raw_ecr_registries"></a> [raw\_ecr\_registries](#input\_raw\_ecr\_registries) | Data structure<br>---------------<br>A list of dictionaries, where each dictionary has the following attributes:<br><br>REQUIRED<br>---------<br>- suffix                      : Suffix to be added to registry name<br><br>OPTIONAL<br>---------<br>- lifecycle\_rules              : A list of dictionaries, where each dictionary is a rule with the following<br>attributes:<br><br>Note: See which map on to https://docs.aws.amazon.com/AmazonECR/latest/userguide/LifecyclePolicies.html#lifecycle_policy_parameters<br>for more information on what is and isn't permissible<br><br>-- rulePriority               : int priority, lowest wins, must be a positive integer.<br>-- description                : OPTIONAL description of the policy, defaults to null<br>-- tagStatus                  : OPTIONAL, determines whether the lifecycle policy rule that you are adding specifies a tag for an image<br>                                Defaults to any<br>-- tagPatternList             : OPTIONAL, specify tag patterns to expire rather than wildcarding.<br>-- tagPrefixList              : OPTIONAL, specify tag patterns to expire, rather than wildcarding.<br>-- countType                  : Specify a count type to apply to the images.<br>-- countUnit                  : Specify a count unit of days to indicate that as the unit of time, in addition to countNumber, which is the number of days.<br>-- countNumber                : Specify a count number. Acceptable values are positive integers (0 is not an accepted value).<br>-- action                     : Only permissible value is expire | <pre>list(<br>    object({<br>      suffix = string,<br>      lifecycle_rules = optional(list(<br>        object({<br>          rulePriority : number,<br>          description : optional(string, null),<br>          tagStatus = optional(string, "any"),<br>          tagPatternList : optional(list(string), null),<br>          tagPrefixList : optional(list(string), null),<br>          countType : string,<br>          countUnit : optional(string, null),<br>          countNumber : number,<br>          action : string<br>        })<br>      ), []),<br>    })<br>  )</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Data structure
```
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
```

## Examples
See `examples` folder for an example setup.
