variable "name" {
  type = string
}

variable "kube_id" {
  type = string
}

variable "flavor_name" {
  type = string
}

variable "max_nodes" {
  type = number
}

variable "min_nodes" {
  type = number
}

variable "monthly_billed" {
  type = bool
}

variable "autoscale" {
  type = bool
}
variable "labels" {
  type = map(string)
}

variable "taints" {
  type = list(map(string))
}
