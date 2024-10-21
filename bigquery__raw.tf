resource google_bigquery_dataset runna_datasets {
    for_each = {
      "activities": {
          "description": "Runna Activities",
      }
    }
    dataset_id        = each.key
    project           = var.project
    description       = each.value.description
    location          = "EU"
}


resource "google_bigquery_table" "raw__fct__activities" {
    project             = var.project
    dataset_id          = google_bigquery_dataset.runna_datasets["activities"].dataset_id
    table_id            = "raw__fct__activities"
    deletion_protection = false

    table_constraints {
        primary_key {
            columns = ["surrogateKey", "extractedAt"] 
        }
    }

    time_partitioning {
        type = "DAY"
        field = "createdAt"
    }

    clustering = [
        "userID"
    ]

    schema = file("schema/fct__activities.json")
}


resource "google_bigquery_table" "dimensions" {
    for_each = toset([
        "dim__plans",
        "dim__workouts",
    ])

    project             = var.project
    dataset_id          = google_bigquery_dataset.runna_datasets["activities"].dataset_id
    table_id            = "raw__${each.value}"
    deletion_protection = false

    table_constraints {
        primary_key {
            columns = ["surrogateKey", "extractedAt"] 
        }
    }

    schema = file("schema/${each.value}.json")
}