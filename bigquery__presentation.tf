resource "google_bigquery_table" "presentation" {
    for_each = toset([
        "fct__activities",
        "dim__plans",
        "dim__workouts",
    ])

    project             = var.project
    dataset_id          = google_bigquery_dataset.runna_datasets["activities"].dataset_id
    table_id            = each.value
    deletion_protection = false

    view {
        query = "SELECT * FROM `runna-task-public.activities.raw__${each.value}` QUALIFY ROW_NUMBER() OVER (PARTITION BY surrogateKey ORDER BY extractedAt DESC) = 1"
        use_legacy_sql = false
    }
}