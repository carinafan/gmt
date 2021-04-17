#---- set up ----

# load data
df_raw = read_excel("../data/iago/event_clean.xlsx",
                    sheet = "Bookkeeping Task 1") %>% 
  as.data.frame()

# set column names
names = c("user_id",
          "date",
          "task",
          "duration")

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
  
  # pull user ID
  temp_id = raw_user_data$user_id[1]
  
  # set up participant dataframe
  temp_df = matrix(data = NA, nrow = 1, ncol = length(names)) %>%
    data.frame()
  
  names(temp_df) = names
  
  # fill in remaining info
  temp_df$user_id = raw_user_data$user_id[1]
  temp_df$date = raw_user_data$created_at[1] %>% 
    date()
  
  # append participant dataframe to overall dataframe
  df %<>% rbind(temp_df)
  
}

#---- data dictionary ----