WITH time_spine AS (

    SELECT
        CAST(
            range AS TIMESTAMP
        ) AS dtm_date

    FROM generate_series(
        TIMESTAMP '1900-01-01 00:00:00',
        CAST(DATE_TRUNC('hour', CURRENT_TIMESTAMP) AS TIMESTAMP),
        INTERVAL '1 hour'
    ) AS t(range)

),

final AS (

    SELECT

        -- Datetime
        dtm_date,

        -- Date
        CAST(dtm_date AS DATE) AS dte_date,

        -- Numeric attributes
        EXTRACT('isoyear' FROM dtm_date) AS num_year,
        EXTRACT('week' FROM dtm_date) AS num_week,
        EXTRACT('month' FROM dtm_date) AS num_month,
        EXTRACT('quarter' FROM dtm_date) AS num_quarter,
        EXTRACT('day' FROM dtm_date) AS num_day,
        EXTRACT('hour' FROM dtm_date) AS num_hour,

        -- Date periods
        DATE_TRUNC('week', dtm_date)::DATE AS dte_week,

        DATE_TRUNC('month', dtm_date)::DATE AS dte_month,

        DATE_TRUNC('quarter', dtm_date)::DATE AS dte_quarter,

        DATE_TRUNC('year', dtm_date)::DATE AS dte_year,

        -- Descriptions
        'Week '
            || LPAD(
                CAST(EXTRACT('week' FROM dtm_date) AS VARCHAR),
                2,
                '0'
            )
            || ', '
            || CAST(EXTRACT('isoyear' FROM dtm_date) AS VARCHAR)
            AS dsc_week,

        STRFTIME(dtm_date, '%B %Y')
            AS dsc_month,

        'Q'
            || CAST(EXTRACT('quarter' FROM dtm_date) AS VARCHAR)
            || ' '
            || CAST(EXTRACT('year' FROM dtm_date) AS VARCHAR)
            AS dsc_quarter,

        CAST(EXTRACT('year' FROM dtm_date) AS VARCHAR)
            AS dsc_year,

        STRFTIME(dtm_date, '%A')
            AS dsc_day,

        STRFTIME(dtm_date, '%A')
            AS dsc_weekday,

        STRFTIME(dtm_date, '%H:00')
            AS dsc_hour

    FROM time_spine

)

SELECT *
FROM final