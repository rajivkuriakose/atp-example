
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}
variable "compartment_ocid" {}

variable "autonomous_database_cpu_core_count" {
  default = 1
}

variable "autonomous_database_data_storage_size_in_tbs" {
  default = 1
}

variable "autonomous_database_db_name" {
  default = "salesdb7"
}


variable "autonomous_database_db_workload" {
  default = "OLTP"
}


variable "autonomous_database_defined_tags_value" {
  default = "value"
}

variable "autonomous_database_display_name" {
  default = "salesdb7"
}


variable "autonomous_database_freeform_tags" {
  default = {
    "Department" = "Sales"
  }
}

variable "autonomous_database_license_model" {
  default = "LICENSE_INCLUDED"
}
