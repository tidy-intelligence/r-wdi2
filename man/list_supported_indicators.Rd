% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/list_supported_indicators.R
\name{list_supported_indicators}
\alias{list_supported_indicators}
\title{List all supported World Bank indicators}
\usage{
list_supported_indicators(language = "en", per_page = 32500)
}
\arguments{
\item{language}{A character string specifying the language for the request, see \link{list_supported_languages}. Defaults to \code{"en"}.}

\item{per_page}{An integer specifying the number of results per page for the API. Defaults to 32,500.
Must be a value between 1 and 32,500.}
}
\value{
A tibble containing the available indicators and their metadata:
\describe{
\item{id}{The ID of the indicator (e.g., "NY.GDP.PCAP.KD").}
\item{name}{The name of the indicator (e.g., "GDP per capita, constant prices").}
\item{source_id}{The ID of the data source providing the indicator.}
\item{source_value}{The name or description of the source of the indicator data.}
\item{source_note}{Additional notes or descriptions about the data source.}
\item{source_organization}{The organization responsible for the data source.}
\item{topics}{A nested tibble containing topics associated with the indicator, with two columns: \code{topic_id} and \code{topic_value}.}
}
}
\description{
This function retrieves a comprehensive list of all indicators supported by the World Bank API.
The indicators include metadata such as the indicator ID, name, unit, source, and associated topics.
The user can specify the language of the API response and whether to include additional details.
}
\details{
This function makes a request to the World Bank API to retrieve metadata for all available indicators.
It processes the response into a tidy tibble format.
}
\examples{

# List all supported indicators in English
list_supported_indicators(language = "en")

# List all supported indicators in Spanish
list_supported_indicators(language = "es")

}
