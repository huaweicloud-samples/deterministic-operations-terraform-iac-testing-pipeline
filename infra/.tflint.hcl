plugin "terraform" {
  enabled = true
}

rule "terraform_deprecated_interpolation" {
  enabled = true
}

rule "terraform_unused_declarations" {
  enabled = true
}

rule "terraform_module_pinned_source" {
  enabled = true
}

rule "terraform_naming_convention" {
  enabled = true
  variable {
    format = "snake_case"
  }
  resource {
    format = "snake_case"
  }
  data {
    format = "snake_case"
  }
}
