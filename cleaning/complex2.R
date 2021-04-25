# Complex Tasks 2

#---- set up ----

# load data
df_raw = read_excel("../data/iago/event_clean.xlsx",
                    sheet = "Complex Task 2") %>% 
  as.data.frame()

# set column names
names = c("user_id",
          "date",
          "order",
          "task",
          "number_done",
          "score",
          "stops",
          "duration")

# find each task starts
started = which(df_raw$tag2 == "Game Started")

# number of starts
n = length(started)

# add 1 to end of start for subsetting last task start
started %<>% append(nrow(df_raw))

# set up empty dataframe
df = data.frame(matrix(data = NA, nrow = 0, ncol = length(names)))
names(df) = names
df$date %<>% ymd()

#---- pull data ----

# for each task start...
for (i in 1:n) {
  
  # subset participant's rows
  range = (started[i]):(started[i+1]-1)
  raw_user_data = df_raw[range, ]
  
  # find task switches
  switches = 1 %>% # set the first row for subsetting
    append(which(raw_user_data$tag2 == "Task Switch")) %>% 
    append(which(raw_user_data$tag2 == "Game Ended")[1])
  
  # if there isn't a "Game Ended" section at the end, add an empty placeholder row
  if (is.na(switches[length(switches)])) {
    raw_user_data %<>% rbind(rep(NA, 7))
    switches[length(switches)] = nrow(raw_user_data)
  }
  
  # set up participant dataframe
  temp_df = matrix(data = NA, nrow = length(switches) - 1, ncol = length(names)) %>%
    data.frame()

  names(temp_df) = names

  # fill in task data

  for (s in 1:(length(switches) - 1)) {

    # subset task rows
    task_range = (switches[s]:(switches[s+1]-1))
    raw_task_data = raw_user_data[task_range, ]
    
    # pull task name
    if (any(grepl("Name Sorting", raw_task_data$tag2))) {
      task = "Name Sorting"
    } else if (any(grepl("Card Sorting", raw_task_data$tag2))) {
      task = "Card Sorting"
    } else if (any(grepl("Dot to Dot", raw_task_data$tag2))) {
      task = "Dot to Dot"
    } else if (any(grepl("Word Search", raw_task_data$tag2))) {
      task = "Word Search"
    } else if (any(grepl("Spot Difference", raw_task_data$tag2))) {
      task = "Spot Difference"
    }
    
    # pull task scores
    if (task == "Name Sorting") {
      
      temp_number_done = raw_task_data %>% 
        filter(grepl("Item Moved. Score is:", tag2)) %>% 
        nrow()

      temp_score = NA

    } else if (task == "Card Sorting") {
      
      temp_number_done = raw_task_data %>% 
        filter(grepl("card sorted", tag2)) %>% 
        nrow()
      
      temp_score = raw_task_data %>% 
        filter(grepl("card sorted: correct", tag2)) %>% 
        nrow()

    } else if (task == "Dot to Dot") {
      
      temp_number_done = raw_task_data %>% 
        filter(grepl("Dot Connected", tag2)) %>% 
        nrow()
      
      temp_score = NA

    } else if (task == "Word Search") {
      
      temp_number_done = raw_task_data %>% 
        filter(grepl("Word Found:", tag2)) %>% 
        nrow()
      
      temp_score = NA

    } else if (task == "Spot Difference") {
      
      temp_number_done = raw_task_data %>% 
        filter(grepl("Different Found", tag2)) %>% 
        nrow()
      
      temp_score = NA
      
    }
    
    # pull stops
    task_stops = raw_task_data %>% 
      filter(tag2 == "Stop Sounded") %>% 
      nrow()
    
    # pull duration
    task_duration = raw_task_data$created_at[1] %>%
      interval(raw_task_data$created_at[nrow(raw_task_data)]) %>%
      time_length("seconds")

    # fill in participant dataframe
    temp_df$task[s] = task
    temp_df$duration[s] = task_duration
    temp_df$number_done[s] = temp_number_done
    temp_df$score[s] = temp_score
    temp_df$stops[s] = task_stops
    
  }

  # fill in remaining info
  temp_df$user_id = raw_user_data$user_id[1]
  temp_df$date = raw_user_data$created_at[1] %>% 
    date()
  temp_df$order = seq(1:(length(switches) - 1))
  
  # append participant dataframe to overall dataframe
  df %<>% rbind(temp_df)
} 
