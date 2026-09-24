library(shiny)
library(bslib)
library(dplyr)
library(ggplot2)

# The solutions folder is one level below the data
students  <- read.csv("../students.csv")
semesters <- read.csv("../semesters.csv")

# Semester records with each student's faculty and study mode
wellbeing_data <- semesters |>
  left_join(students |> select(student_id, faculty, study_mode), join_by(student_id))

measures <- c("Wellbeing (0-100)" = "wellbeing",
              "Sleep (hours a night)" = "sleep_hours",
              "Study (hours a week)" = "study_hours")

ui <- page_sidebar(
  title = "Graduate student wellbeing",
  sidebar = sidebar(
    selectInput("faculty", "Faculty", choices = sort(unique(wellbeing_data$faculty))),
    radioButtons("measure", "Measure", choices = measures),
    sliderInput("semesters", "Semesters", min = 1, max = 4, value = c(1, 4), step = 1)
  ),
  card(plotOutput("trend")),
  card(tableOutput("summary"))
)

server <- function(input, output, session) {
  selected <- reactive({
    wellbeing_data |>
      filter(faculty == input$faculty,
             between(semester, input$semesters[1], input$semesters[2]))
  })

  output$trend <- renderPlot({
    selected() |>
      summarise(mean = mean(.data[[input$measure]], na.rm = TRUE),
                .by = c(semester, study_mode)) |>
      ggplot(aes(x = semester, y = mean, colour = study_mode)) +
      geom_line(linewidth = 1) +
      geom_point(size = 3) +
      labs(x = "Semester", y = names(measures)[measures == input$measure],
           colour = "Study mode") +
      theme_minimal(base_size = 14)
  })

  output$summary <- renderTable({
    selected() |>
      summarise(students = n_distinct(student_id),
                mean = mean(.data[[input$measure]], na.rm = TRUE),
                .by = semester)
  })
}

shinyApp(ui, server)
