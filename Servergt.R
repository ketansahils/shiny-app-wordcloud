server <- function(input, output) {
  
  infile <- reactive({
    infile <- input$datafile
    if (is.null(infile)) {
      # User has not uploaded a file yet
      return(NULL)
    }
    # df = read.csv(inFile$datapath, header = input$header)
    return(readLines(infile$datapath))
  })
  
  annotate_data = reactive({
    nokia =  (infile())
    nokia  =  str_replace_all(nokia, "<.*?>", "") # get rid of html junk
    str(nokia)
    # ?udpipe_download_model   # for langu listing and other details
    if(identical(nokia,character(0)))
    {
      return(data.frame(doc_id=character(), 
                        paragraph_id=character(),
                        sentence_id=character(),
                        token_id=character(),
                        token=character(),
                        lemma=character(),
                        upos=character(),
                        xpos=character(),
                        feats=character(),
                        head_token_id=character(),
                        dep_rel=character(),
                        deps=character(),
                        misc=character(),
                        stringsAsFactors=FALSE) )
    }
    # load english model for annotation from working dir
    english_model = udpipe_load_model("model/english-ud-2.0-170801.udpipe")  # file_model only needed
    
    # now annotate text dataset using ud_model above
    # system.time({   # ~ depends on corpus size
    x <- udpipe_annotate(english_model, x = nokia) #%>% as.data.frame() %>% head()
    x <- as.data.frame(x)
    x <- subset(x,select=-c(sentence))
    return(x)
  })
  
  
  # str(x);
  output$annotated_df = renderDataTable({
    head(annotate_data(),100)
  })
  
  output$dwnld =downloadHandler(
    filename = function() {
      paste('data-', Sys.Date(), '.csv', sep='')
    },
    content = function(con) {
      write.csv(annotate_data(), con)
    }
  )
  
  #output$renderPlotFunc = reactive(function(){
  output$renderPlotFunc = renderPlot({
    x = annotate_data()
    #print(input$select_plot)
    if(input$cloud_type == "wordcloud_plot")
    {
      all_nouns = x %>% subset(., upos %in% "NOUN") 
      top_nouns = txt_freq(all_nouns$lemma)  # txt_freq() calcs noun freqs in desc order
      wordcloud(words = top_nouns$key,scale = c(8,1),
                freq = top_nouns$freq,
                min.freq = input$min_freq,
                max.words = input$max_word,
                random.order = FALSE,
                colors = brewer.pal(6, "Dark2"))
    } else {
      all_verbs = x %>% subset(., upos %in% "VERB")
      top_verbs = txt_freq(all_verbs$lemma)
      wordcloud(words = top_verbs$key, scale = c(8,1),
                freq = top_verbs$freq,
                min.freq = input$min_freq,
                max.words = input$max_word,
                random.order = FALSE,
                colors = brewer.pal(6, "Dark2")) 
    }
  })
  
  output$network_plot = renderPlot({
    # Sentence Co-occurrences for nouns or adj only
    nokia_cooc <- cooccurrence(   	# try `?cooccurrence` for parm options
      x = subset(annotate_data(), upos %in% c(input$checkGroup)), 
      term = "lemma", 
      group = c("doc_id", "paragraph_id", "sentence_id"))  # 0.02 secs
    
    wordnetwork <- head(nokia_cooc, 30)
    wordnetwork <- igraph::graph_from_data_frame(wordnetwork) # needs edgelist in first 2 colms.
    
    ggraph(wordnetwork, layout = "fr") +  
      
      geom_edge_link(aes(width = cooc, edge_alpha = cooc), edge_colour = "orange") +  
      geom_node_text(aes(label = name), col = "darkgreen", size = 4) +
      
      theme_graph(base_family = "Arial Narrow") +  
      theme(legend.position = "none") +
      
      labs(title = "Cooccurrences within 3 words distance", subtitle = "Nouns & Adjective")
  })
}
