from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck
from checkov.common.models.enums import CheckResult, CheckCategories


class S3EncryptionCheck(BaseResourceCheck):
    def __init__(self):
        name = "Ensure S3 bucket has server-side encryption enabled"
        id = "CKV_CUSTOM_S3_1"
        supported_resources = ["aws_s3_bucket"]
        categories = (CheckCategories.ENCRYPTION,)
        super().__init__(
            name=name,
            id=id,
            categories=categories,
            supported_resources=supported_resources,
        )

    def scan_resource_conf(self, conf):
        if "server_side_encryption_configuration" in conf:
            return CheckResult.PASSED
        return CheckResult.FAILED


check = S3EncryptionCheck()
