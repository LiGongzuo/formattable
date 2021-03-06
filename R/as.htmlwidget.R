#' Generic function to create an htmlwidget
#'
#' This function is a generic function to create an \code{htmlwidget}
#' to allow HTML/JS from R in multiple contexts.
#'
#' @param x an object.
#' @param ... arguments to be passed to methods.
#' @export
#' @return a \code{htmlwidget} object
as.htmlwidget <- function(x, ...)
  UseMethod("as.htmlwidget")


#' Convert formattable to an htmlwidget
#'
#' formattable was originally designed to work in \code{rmarkdown} environments.
#' Conversion of a formattable to a htmlwidget will allow use in other contexts
#' such as console, RStudio Viewer, and Shiny.
#'
#' @param x a \code{formattable} object to convert
#' @param width a valid \code{CSS} width
#' @param height a valid \code{CSS} height
#' @param ... reserved for more parameters
#' @return a \code{htmlwidget} object
#'
#' @examples
#' \dontrun{
#' library(formattable)
#' # mtcars (mpg background in gradient: the higher, the redder)
#' as.htmlwidget(
#'   formattable(mtcars, list(mpg = formatter("span",
#'    style = x ~ style(display = "block",
#'    "border-radius" = "4px",
#'    "padding-right" = "4px",
#'    color = "white",
#'    "background-color" = rgb(x/max(x), 0, 0))))
#'   )
#' )
#'
#' # since an htmlwidget, composes well with other tags
#' library(htmltools)
#'
#' browsable(
#'   tagList(
#'     tags$div( class="jumbotron"
#'               ,tags$h1( class = "text-center"
#'                         ,tags$span(class = "glyphicon glyphicon-fire")
#'                         ,"experimental as.htmlwidget at work"
#'               )
#'     )
#'     ,tags$div( class = "row"
#'                ,tags$div( class = "col-sm-2"
#'                           ,tags$p(class="bg-primary", "Hi, I am formattable htmlwidget.")
#'                )
#'                ,tags$div( class = "col-sm-6"
#'                           ,as.htmlwidget( formattable( mtcars ) )
#'                )
#'     )
#'   )
#' )
#' }
#' @importFrom markdown markdownToHTML
#' @importFrom htmlwidgets createWidget
#'
#' @export
#'
as.htmlwidget.formattable <- function(x, width = "100%", height = NULL, ...) {
  if(!is.formattable(x)) stop("expect formattable to be a formattable", call. = FALSE)
  html <- gsub( # change align to bootstrap class for align
    x = markdown::markdownToHTML(
      text = gsub(x = as.character(x), pattern = "\n", replacement = "") #remove line breaks
      ,fragment.only = TRUE
    )
    ,pattern = 'align=\"'
    ,replacement = 'class=\"text-'
  )
  md <- as.character(x)
  # forward options using x
  x <- list(html = html, md = md)

  # create widget
  htmlwidgets::createWidget(name = 'formattable_widget', x, width = width,
    height = height, package = 'formattable')
}

#' @importFrom shiny bootstrapPage
#' @importFrom htmltools tags
formattable_widget_html <- function(name, package, id, style, class, width, height) {
  shiny::bootstrapPage(htmltools::tags$div(id = id, class = class, style = style))
}
