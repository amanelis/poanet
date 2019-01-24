## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| env\_short | The short namespace for the environment | string | n/a | yes |
| environment | The namespace of the environment | string | n/a | yes |
| external\_zone | Default base zone_id | string | n/a | yes |
| key\_name | AWS pem key for SSH access | string | n/a | yes |
| private\_key | Full path location for $key_name | string | n/a | yes |
| region | The AWS region to allocate resources in | string | n/a | yes |
| vpc\_cidr | The CIDR range to use for the VPC | string | n/a | yes |
| zones | The number of AZs to bring resources up in | string | `"2"` | no |

