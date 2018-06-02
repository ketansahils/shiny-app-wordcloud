shinyUI(dashboardPage(
  
  dashboardHeader(title = "Text Analytics"),
  dashboardSidebar( width = 0, 
                    "text"
  ),
  dashboardBody(
    tags$head(tags$style(HTML('.content-wrapper,
                              .right-side {
                              background-color: #ffffff;
                              }'))),
      tabsetPanel(
        tabPanel(title="Home",
                 div(style = 'margin-left:100px;margin-top:30px;text-align: justify;',
                     p(style = 'color:darkblue;font-size: 30px',"Text Analytics "),
                     p(style = 'color:black;font-size: 18px;font-style:italic',"Shiny app has these features."),
                     p(style = 'color:black;font-size: 18px;font-style:italic',"A - Should be able to read any text file using standard upload functionality.
                       "),
                     p(style = 'color:black;font-size: 18px;font-style:italic',"B - English language model should be included in the same directory from which Global.R is run.
                       "),
                     p(style = 'color:black;font-size: 18px;font-style:italic',"
                       C - User should be able to select list of Universal part-of-speech tags (upos) using check box for plotting co-occurrences. List of upos required in app - 
                       adjective (ADJ),
                       noun(NOUN),
                       proper noun (PROPN),
                       adverb (ADV),
                       verb (VERB),
                       Default selection should be adjective (ADJ), noun (NOUN), proper noun (PROPN). Based on upos selection, filter annotated document and build co-occurrences plot"))
                     ),
        tabPanel(title="Data",
                 fileInput("datafile", "Choose CSV File",
                           multiple = TRUE,
                           accept = c("text/csv",
                                      "text/comma-separated-values,text/plain",
                                      ".csv")),
                 downloadButton("dwnld", label = "Download"),
                 dataTableOutput("annotated_df")
        ),
        tabPanel(title="Word Cloud",
                 fluidRow(
                           div(style='text-align:center;',h1("Wordcloud Viewer")),
                           hr(),
                           sidebarPanel(
                             selectInput("cloud_type", h3("Select Cloud Type"), 
                                         choices = list("Wordcloud for Nouns" = "wordcloud_plot", 
                                                        "Wordcloud for Verbs" = "wordcloud_2")),
                             hr(),
                             sliderInput("min_freq", 
                                         "Min. Freq:", 
                                         min = 1,
                                         max = 100,
                                         value = 2),
                             sliderInput("max_word", 
                                         "Max Word count:", 
                                         min = 1,
                                         max = 500,
                                         value = 100)
                           ),
                           mainPanel(
                             plotOutput("renderPlotFunc"))
                 )
        ),
        tabPanel(title="Plot",
                 checkboxGroupInput("checkGroup", 
                                    label = h3("Select UPOS tag"), 
                                    choices = list("adjective" ="ADJ",
                                                   "noun"="NOUN",
                                                   "proper noun"="PROPN",
                                                   "adverb" ="ADV",
                                                   "verb"= "VERB"),
                                    selected = c("ADJ","NOUN")
                 ),
                 plotOutput("network_plot")
        )
                     )
                     )
  
  )
)
