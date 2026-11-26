# ============================================================
# OBS Buckets for Build Artifacts
# ============================================================

# OBS bucket for pipeline artifacts
resource "huaweicloud_obs_bucket" "pipeline_artifacts" {
  bucket        = "${var.obs_bucket_name_prefix}-pipeline-${random_id.suffix.hex}"
  acl           = "private"
  force_destroy = true
  versioning    = true
  encryption    = true
  kms_key_id    = huaweicloud_kms_key.artifact_key.id

  tags = var.custom_tags
}

# OBS bucket for build logs
resource "huaweicloud_obs_bucket" "build_logs" {
  bucket        = "${var.obs_bucket_name_prefix}-logs-${random_id.suffix.hex}"
  acl           = "private"
  force_destroy = true
  versioning    = true
  encryption    = true
  kms_key_id    = huaweicloud_kms_key.artifact_key.id

  tags = var.custom_tags
}

# KMS key for encrypting artifacts at rest
resource "huaweicloud_kms_key" "artifact_key" {
  key_alias       = "${var.obs_bucket_name_prefix}-key-${random_id.suffix.hex}"
  pending_days    = "7"
  key_description = "KMS key for encrypting CI/CT pipeline artifacts"
}
