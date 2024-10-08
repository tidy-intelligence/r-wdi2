#' Internal function to perform API requests to the World Bank API
#'
#' This function constructs and sends a request to the specified World Bank API resource,
#' with options to specify the language, the number of results per page, a date range,
#' and the data source. It also supports paginated requests and progress tracking.
#'
#' @param resource A character string specifying the resource endpoint for the World Bank API (e.g., "incomeLevels", "lendingTypes").
#' @param language A character string specifying the language code for the API response. Defaults to NULL.
#' @param per_page An integer specifying the number of results per page for the API. Defaults to 1000.
#' Must be a value between 1 and 32,500.
#' @param date A character string specifying the date range of the data to be retrieved (e.g., "2000:2020").
#' If NULL (default), no date filtering is applied.
#' @param source A character string specifying the data source for the API request. If NULL (default),
#' no specific source is selected.
#' @param progress A logical value indicating whether to display a progress bar for paginated requests.
#' Defaults to FALSE.
#' @param base_url A character string specifying the base URL of the World Bank API (default is "https://api.worldbank.org/v2").
#'
#' @return A list containing the parsed JSON response from the API. If the response contains multiple pages,
#' the results are combined into a single list. If the API returns an error, it provides the relevant error message and documentation.
#'
#' @details This internal helper function constructs the request URL using the base URL, language, resource, and other optional parameters
#' (such as date and source), and performs the API request. For paginated results, it iterates through all pages and
#' consolidates the data into a single output. The function handles API errors, providing detailed error messages when available.
#'
#' @keywords internal
#'
perform_request <- function(
    resource,
    language = NULL,
    per_page = 1000,
    date = NULL,
    source = NULL,
    progress = FALSE,
    base_url = "https://api.worldbank.org/v2/"
  ) {

  if (!is.numeric(per_page) || per_page %% 1L != 0 || per_page < 1L || per_page > 32500L) {
    cli::cli_abort("{.arg per_page} must be an integer between 1 and 32,500.")
  }

  is_request_error <- function(resp) {
    status <- resp_status(resp)
    if (status >= 400L) {
      return(TRUE)
    }
    body <- resp_body_json(resp)
    if (length(body) == 1L && length(body[[1L]]$message) == 1L) {
      return(TRUE)
    }
    FALSE
  }

  check_for_body_error <- function(resp) {
    content_type <- resp_content_type(resp)
    if (identical(content_type, "application/json")) {
      body <- resp_body_json(resp)
      message_id <- body[[1]]$message[[1]]$id
      message_value <- body[[1]]$message[[1]]$value
      error_code <- paste("Error code:", message_id)
      docs <- "Read more at <https://datahelpdesk.worldbank.org/knowledgebase/articles/898620-api-error-codes>"
      c(error_code, message_value, docs)
    }
  }

  req <- request(base_url) |>
    req_url_path_append(language, resource) |>
    req_url_query(format = "json", per_page = per_page, date = date, source = source) |>
    req_user_agent("wbwdi R package (https://github.com/tidy-intelligence/r-wbwdi)")

  resp <- req_perform(req)

  if (is_request_error(resp)) {
    error_body <- check_for_body_error(resp)
  }

  body <- resp_body_json(resp)

  pages <- body[[1L]]$pages

  if (pages == 1L) {
    out <- body[[2L]]
  } else {
    resps <- req |>
      req_perform_iterative(next_req = iterate_with_offset("page"),
                            max_reqs = pages,
                            progress = progress)
    out <- resps |>
      purrr::map(function(x) {resp_body_json(x)[[2]]})
    out <- unlist(out, recursive = FALSE)
  }
  out
}
