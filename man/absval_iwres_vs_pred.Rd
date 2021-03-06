% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot_resiudals.R
\name{absval_iwres_vs_pred}
\alias{absval_iwres_vs_pred}
\title{Absolute value of individual weighted residuals (IWRES) plotted against population predictions (PRED)}
\usage{
absval_iwres_vs_pred(xpdb, aes = NULL, group = "ID", type = "pls",
  facets = NULL, title = NULL, subtitle = NULL, caption = NULL,
  log = NULL, guides = TRUE, ...)
}
\arguments{
\item{xpdb}{An xpose database object.}

\item{aes}{The xpose aesthetics (eg. \code{point_color}).}

\item{group}{Grouping variable to be used for lines.}

\item{type}{String setting the type of plot to be used points 'p',
line 'l' and smooth 's' or any combination of the three.}

\item{facets}{Either a character string to use \link[ggplot2]{facet_wrap} or a formula 
to use \link[ggplot2]{facet_grid}.}

\item{title}{Main title of the plot. If NULL automated title will be generated.
Use \code{FALSE} to remove title and subtitle.}

\item{subtitle}{the plot subtitle. If NULL automated subtitle will be generated.
Use \code{FALSE} to remove subtitle.}

\item{caption}{page caption. If NULL automated caption will be generated.
Use \code{FALSE} to remove caption.}

\item{log}{String assigning logarithmic scale to axes, can be either '', 'x', y' or 'xy'.}

\item{guides}{Enable guides display (e.g. unity line).}

\item{...}{Any additional aesthetics to be passed on \code{xplot_scatter}.}
}
\description{
Plot of absolute value of individual weighted residuals (IWRES) plotted against population predictions (PRED).
}
\section{Template titles}{

Template titles can be used to create highly informative diagnostics plots. 
They can be applied to any plot title, subtitle and caption. Template titles 
are defined via a single string containing key variables staring with a @ (e.g. @ofv)
which will be replaced by their actual value when rendering the plot.
For example '@run, @nobs observations in @nind subjects' would become 'run001, 
1022 observations in 74 subjects'. The available key variables are listed under 
\code{\link{template_titles}}.
}

\examples{
absval_iwres_vs_pred(xpdb_ex_pk)

}
\seealso{
\code{\link{xplot_scatter}}
}
