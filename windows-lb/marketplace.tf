## Copyright (c) 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_marketplace_accepted_agreement" "Accepted_Agreement" {
  agreement_id    = oci_marketplace_listing_package_agreement.Listing_Package_Agreement.agreement_id
  compartment_id  = var.compartment_ocid
  listing_id      = data.oci_marketplace_listing.Listing.id
  package_version = data.oci_marketplace_listing.Listing.default_package_version
  signature       = oci_marketplace_listing_package_agreement.Listing_Package_Agreement.signature
}

resource "oci_marketplace_listing_package_agreement" "Listing_Package_Agreement" {
  agreement_id    = data.oci_marketplace_listing_package_agreements.Listing_Package_Agreements.agreements.0.id
  listing_id      = data.oci_marketplace_listing.Listing.id
  package_version = data.oci_marketplace_listing.Listing.default_package_version
}

data "oci_marketplace_listing_package_agreements" "Listing_Package_Agreements" {
  listing_id      = data.oci_marketplace_listing.Listing.id
  package_version = data.oci_marketplace_listing.Listing.default_package_version
  compartment_id  = var.compartment_ocid
}

data "oci_marketplace_listing_package" "Listing_Package" {
  listing_id      = data.oci_marketplace_listing.Listing.id
  package_version = data.oci_marketplace_listing.Listing.default_package_version
  compartment_id  = var.compartment_ocid
}

data "oci_marketplace_listing_packages" "Listing_Packages" {
  listing_id     = data.oci_marketplace_listing.Listing.id
  compartment_id = var.compartment_ocid
}

data "oci_marketplace_listing" "Listing" {
  listing_id     = data.oci_marketplace_listings.Listings.listings.0.id
  compartment_id = var.compartment_ocid
}

data "oci_marketplace_listings" "Listings" {
  name           = ["Microsoft SQL 2016 Enterprise with Windows Server 2016 Standard"]
  compartment_id = var.compartment_ocid
}

data "oci_core_app_catalog_listing" "App_Catalog_Listing" {
  listing_id = data.oci_marketplace_listing_package.Listing_Package.app_catalog_listing_id
}

data "oci_core_app_catalog_listing_resource_versions" "App_Catalog_Listing_Resource_Versions" {
  listing_id = data.oci_marketplace_listing_package.Listing_Package.app_catalog_listing_id
}

data "oci_core_app_catalog_listing_resource_version" "App_Catalog_Listing_Resource_Version" {
  listing_id       = data.oci_marketplace_listing_package.Listing_Package.app_catalog_listing_id
  resource_version = data.oci_core_app_catalog_listing_resource_versions.App_Catalog_Listing_Resource_Versions.app_catalog_listing_resource_versions[0].listing_resource_version
}

resource "oci_core_app_catalog_listing_resource_version_agreement" "App_Catalog_Listing_Resource_Version_Agreement" {
  listing_id               = data.oci_marketplace_listing_package.Listing_Package.app_catalog_listing_id
  listing_resource_version = data.oci_core_app_catalog_listing_resource_versions.App_Catalog_Listing_Resource_Versions.app_catalog_listing_resource_versions[0].listing_resource_version
}

resource "oci_core_app_catalog_subscription" "App_Catalog_Subscription" {
  compartment_id           = var.compartment_ocid
  eula_link                = oci_core_app_catalog_listing_resource_version_agreement.App_Catalog_Listing_Resource_Version_Agreement.eula_link
  listing_id               = oci_core_app_catalog_listing_resource_version_agreement.App_Catalog_Listing_Resource_Version_Agreement.listing_id
  listing_resource_version = oci_core_app_catalog_listing_resource_version_agreement.App_Catalog_Listing_Resource_Version_Agreement.listing_resource_version
  oracle_terms_of_use_link = oci_core_app_catalog_listing_resource_version_agreement.App_Catalog_Listing_Resource_Version_Agreement.oracle_terms_of_use_link
  signature                = oci_core_app_catalog_listing_resource_version_agreement.App_Catalog_Listing_Resource_Version_Agreement.signature
  time_retrieved           = oci_core_app_catalog_listing_resource_version_agreement.App_Catalog_Listing_Resource_Version_Agreement.time_retrieved
}
