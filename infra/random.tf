# ============================================================
# Random suffix for unique resource naming
# ============================================================

resource "random_id" "suffix" {
  byte_length = 4
}
