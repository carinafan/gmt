# Complex Tasks 1

#---- set up ----

# load data
df_raw = read_excel("../data/iago/event_clean.xlsx",
                    sheet = "Complex Task 1") %>% 
  as.data.frame()

# set column names
names = c("user_id",
          "date",
          "order",
          "task",
          "number_done",
          "score",
          "duration")
# find each task start
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
  
  # set up participant dataframe
  temp_df = matrix(data = NA, nrow = length(switches) - 1, ncol = length(names)) %>% 
    data.frame()
  
  names(temp_df) = names
  
  # fill in user ID, date, task order
  temp_df$user_id = raw_user_data$user_id[1]
  temp_df$date = raw_user_data$created_at[1] %>% 
    date()
  temp_df$order = seq(1:(length(switches)-1))
  
  # fill in task data
  
  # for (s in 1:(length(switches) - 1)) {
  #   
  # }
  
  # append participant dataframe to overall dataframe
  df %<>% rbind(temp_df)
}
