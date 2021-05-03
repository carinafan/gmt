# Complex Tasks 3

#---- set up ----

# load data
df_raw = read_excel("../data/iago/event_clean.xlsx",
                    sheet = "Complex Task 3") %>% 
  as.data.frame()

# set column names
names = c("user_id",
          "date",
          "order",
          "task",
          "number_done",
          "score",
          "duration")

# set task names
tasks = c("Card Sorting",
          "Name Sorting",
          "Dot to Dot",
          "Spot Difference",
          "Word Search")

# find each task starts
started = which(df_raw$tag2 == "Started")

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
    
    # check for task name
    temp_task_rows = raw_task_data %>% 
      filter(tag2 %in% tasks) %>% 
      select(tag2)

    # if there is only 1 task name present, pull scores
    if (nrow(temp_task_rows) == 1) {
      
      # pull task name
      if (temp_task_rows$tag2 == "Name Sorting") {
        temp_task = "Name Sorting"
      } else if (temp_task_rows$tag2 == "Card Sorting") {
        temp_task = "Card Sorting"
      } else if (temp_task_rows$tag2 == "Dot to Dot") {
        temp_task = "Dot to Dot"
      } else if (temp_task_rows$tag2 == "Word Search") {
        temp_task = "Word Search"
      } else if (temp_task_rows$tag2 == "Spot Difference") {
        temp_task = "Spot Difference"
      }
      
      # pull task scores
      if (temp_task == "Name Sorting") {
        
        temp_number_done = raw_task_data %>% 
          filter(grepl("Item Moved. Score is:", tag2)) %>% 
          nrow()
        
        temp_score = raw_task_data %>% 
          filter(grepl("Item Moved. Score is:", tag2)) %>% 
          select(tag3) %>% 
          slice(temp_number_done) %>% 
          pull()
        
        if (identical(temp_score, character(0))) {
          temp_score = NA
        }
        
      } else if (temp_task == "Card Sorting") {
        
        temp_number_done = raw_task_data %>% 
          filter(grepl("card sorted", tag2)) %>% 
          nrow()
        
        temp_score = raw_task_data %>% 
          filter(grepl("card sorted: correct", tag2)) %>% 
          nrow()
        
      } else if (temp_task == "Dot to Dot") {
        
        temp_number_done = raw_task_data %>% 
          filter(grepl("Dot Connected", tag2)) %>% 
          nrow()
        
        temp_score = NA
        
      } else if (temp_task == "Word Search") {
        
        temp_number_done = raw_task_data %>% 
          filter(grepl("Word Found:", tag2)) %>% 
          nrow()
        
        temp_score = NA
        
      } else if (temp_task == "Spot Difference") {
        
        temp_number_done = raw_task_data %>% 
          filter(grepl("Different Found", tag2)) %>% 
          nrow()
        
        temp_score = NA
        
      }
      
    } else { # otherwise put NAs, to be filled manually
      
      temp_task = NA
      temp_number_done = NA
      temp_score = NA
      
    }

    # remove Game Started rows so they don't mess up duration
    raw_task_data %<>%
      filter(tag2 != "Game Started")
    
    # pull duration
    task_duration = raw_task_data$created_at[1] %>%
      interval(raw_task_data$created_at[nrow(raw_task_data)]) %>%
      time_length("seconds")

    # fill in participant dataframe
    temp_df$task[s] = temp_task
    temp_df$duration[s] = task_duration
    temp_df$number_done[s] = temp_number_done
    temp_df$score[s] = temp_score
    
  }

  # fill in remaining info
  temp_df$user_id = raw_user_data$user_id[1]
  temp_df$date = raw_user_data$created_at[1] %>% 
    date()
  temp_df$order = seq(1:(length(switches) - 1))
  
  # append participant dataframe to overall dataframe
  df %<>% rbind(temp_df)
} 

#---- hard code fixes ----

df = df[-c(5, 117, 127, 133), ]
