variable "name" {
    description = "Test"
    type = string
}

output "test" {
    value = "Hello, %{ if var.name != "" }${ var.name }%{ else }(unnamed)%{ endif }"
}
