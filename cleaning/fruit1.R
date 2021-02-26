# Fruit Clapping Task 1 
# this script shares a workspace with gmt_cleaning.Rmd
# and should only be called in the conntext of that file

#---- set up ----

rm(list=ls())

# load datat
df_raw = read_excel("../data/iago/event_clean.xlsx",
                    sheet = "Fruit Task 1") %>% 
  as.data.frame()

# set column names
names = c(
  "user_id",
  "date",
  "duration",
  "non_pears_shown",
  "non_pears_correct",
  "pears_shown",
  "pears_correct"
)

# find each task start
started = which(df_raw$tag2 == "Started")

# number of starts
n = length(started)

# add 1 to end of start for subsetting last task start
started %<>% append(nrow(df_raw))

# set up empty dataframe
df = data.frame(matrix(data = NA, nrow = n, ncol = length(names)))
names(df) = names

#---- pull data ----

# for each task start...
for (i in 1:n) {
  
  # subset participant's rows
  range = (started[i]):(started[i+1]-1)
  raw_user_data = df_raw[range, ]
  
  # check that user ID matches throughout
  # if (raw_user_data %>% select(user_id) %>% unique() %>% nrow() == 1) {
  #   temp_id = raw_user_data$user_id[1]
  # } else {
  #   print("Error: multiple IDs")
  #   break
  # }
  
  # pull user ID
  temp_id = raw_user_data$user_id[1]
  
  # pull date
  temp_date = raw_user_data$created_at[1] %>% 
    date()
  
  # pull duration
  temp_duration = raw_user_data$created_at[1] %>% 
    interval(raw_user_data$created_at[nrow(raw_user_data)]) %>% 
    time_length("seconds")
  
  # pull non-pears
  temp_nonpears = raw_user_data %>% 
    filter(tag2 != "Started",
           tag2 != "pear",
           tag2 != "Game Ended")
  
  temp_nonpears_shown = temp_nonpears %>% 
    nrow()
  
  temp_nonpears_correct = temp_nonpears %>% 
    filter(tag3 == "correct") %>% 
    nrow()
  
  # pull pears
  temp_pears = raw_user_data %>% 
    filter(tag2 == "pear")
  
  temp_pears_shown = temp_pears %>% 
    nrow()
  
  temp_pears_correct = temp_pears %>% 
    filter(tag3 == "correct") %>% 
    nrow()
  
  # fill in daatframe
  df$user_id[i] = temp_id
  df$date[i] = temp_date
  df$duration[i] = temp_duration
  df$non_pears_shown[i] = temp_nonpears_shown
  df$non_pears_correct[i] = temp_nonpears_correct
  df$pears_shown[i] = temp_pears_shown
  df$pears_correct[i] = temp_pears_correct
  
}

#---- clean up ----

df %>% 
  write.xlsx("../data/gmt_clean.xlsx",
             sheetName = "fruit1",
             row.names = FALSE,
             append = TRUE)
